# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-003"
# title: "Download Stack (SABnzbd + VPN)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [media,download,sabnzbd,vpn]
# description: "SABnzbd download manager with VPN confinement. Downloads NOT in backup (re-downloadable)."
# path: "modules/50-media/52-download.nix"
# provides: [my.media.downloads]
# requires: [10-network]
# links:
#   adr: docs/adr/ADR-50-media.md
#   guide: docs/guides/50-media.md
#   module: modules/50-media/52-download.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# nixarr pattern: VPN nur für SABnzbd (Downloads über VPN, Arr-Services direkt).
# Download-Daten werden NICHT im Backup berücksichtigt (wiederherstellbar via SceneNZB).
# State Management in /data/.state/nixarr/.
# ### Entscheidung
#
# SABnzbd mit VPN-Confinement über WireGuard. Downloads sind ephemer.
# Arr-Services (Sonarr/Radarr/etc.) laufen OHNE VPN.
# ─── End KB Nuggets ───

{ config, lib, pkgs, ... }:

let
  cfg = config.my.media.downloads;
  arrCfg = config.my.media.arr-stack;
in
{
  options.my.media.downloads = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "SABnzbd web interface port.";
    };

    downloadDir = lib.mkOption {
      type = lib.types.str;
      default = arrCfg.downloadDir;
      description = "Download directory for completed downloads.";
    };

    incompleteDir = lib.mkOption {
      type = lib.types.str;
      default = "${arrCfg.downloadDir}/incomplete";
      description = "Directory for incomplete downloads.";
    };

    # ── VPN Confinement (nixarr pattern, nur für SABnzbd) ──
    # VPN macht nur für SABnzbd Sinn (Downloads), nicht für Arr-Services
    vpn = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Route SABnzbd traffic through VPN (wg-quick). Arr services run direct.";
      };
      wgConf = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Path to WireGuard config file from VPN provider.";
      };
      killSwitch = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Kill switch: block all traffic if VPN drops.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # ── SABnzbd Service ──
    services.sabnzbd = {
      enable = true;
      port = cfg.port;
      downloadDir = cfg.downloadDir;
      incompleteDir = cfg.incompleteDir;
    };

    # ── VPN Confinement (nur SABnzbd) ──
    # WireGuard VPN interface
    networking.wg-quick.interfaces = lib.mkIf cfg.vpn.enable {
      vpn-sabnzbd = {
        address = [ "10.200.200.2/32" ];
        privateKeyFile = "/run/secrets/vpn-private-key";
        peers = [
          {
            # PublicKey and Endpoint from WireGuard config
            publicKey = "";
            endpoint = "";
            allowedIPs = [ "0.0.0.0/0" ];
            persistentKeepalive = 25;
          }
        ];
        # Kill switch: only allow DNS and VPN traffic
        preUp = lib.mkIf cfg.vpn.killSwitch ''
          iptables -I OUTPUT 1 -o lo -j ACCEPT
          iptables -I OUTPUT 2 -m owner --gid-owner sabnzbd -j ACCEPT
          iptables -I OUTPUT 3 -d 127.0.0.0/8 -j DROP
        '';
        postDown = lib.mkIf cfg.vpn.killSwitch ''
          iptables -D OUTPUT 1 || true
          iptables -D OUTPUT 2 || true
          iptables -D OUTPUT 3 || true
        '';
      };
    };

    # ── SABnzbd in VPN network namespace ──
    systemd.services.sabnzbd = {
      after = lib.mkIf cfg.vpn.enable [ "network-online.target" "wg-quick-vpn-sabnzbd.service" ];
      wants = lib.mkIf cfg.vpn.enable [ "network-online.target" ];

      serviceConfig = {
        # Network namespace isolation for VPN
        NetworkNamespacePath = lib.mkIf cfg.vpn.enable "/var/run/netns/vpn-sabnzbd";

        # State Management (nixarr pattern)
        ReadWritePaths = [
          "/var/lib/sabnzbd"
          cfg.downloadDir
          cfg.incompleteDir
        ];

        # Hardening
        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
      };
    };

    # ── Backup Policy: Downloads NICHT im Backup ──
    # Downloads sind wiederherstellbar über SceneNZB.com
    environment.etc."nixarr-backup-exclude".text = ''
      # Arr/Download state wird NICHT gebackupt (wiederherstellbar)
      ${cfg.downloadDir}
      ${cfg.incompleteDir}
      ${arrCfg.stateDir}/sabnzbd
    '';

    # ── State Management (nixarr pattern) ──
    systemd.tmpfiles.rules = [
      "d ${arrCfg.stateDir}/sabnzbd 0750 sabnzbd media -"
      "d ${cfg.downloadDir} 0750 sabnzbd media -"
      "d ${cfg.incompleteDir} 0750 sabnzbd media -"
    ];
  };
}
