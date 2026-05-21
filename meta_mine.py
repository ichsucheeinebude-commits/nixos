#!/usr/bin/env python3
"""
MetaBibliothek Miner — Extract gold from grapefruit89/mynixos and inject into nixos-work.

Extracts:
1. mkService helper library (core pattern)
2. Defaults system (ABC tiering paths, locale, security)
3. Port registry (central port mapping)
4. NMS metadata patterns (options.my.meta.*)
5. Systemd hardening patterns
6. Caddy SSO integration
7. Socket activation (Wake-on-Access)
8. Secret mapping system
9. Config merger pattern
10. Registry (master switchboard)
"""

import os
import subprocess

TARGET = "/root/nixos-work"
META = "/root/_meta"

def w(path, content):
    full = os.path.join(TARGET, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, 'w') as f:
        f.write(content)
    print(f"  ✓ {path}")

def run(cmd):
    r = subprocess.run(cmd, shell=True, capture_output=True, text=True, cwd=TARGET)
    return r.stdout.strip()

# ═══════════════════════════════════════════════════════
# 1. MKSERVICE HELPER LIBRARY
# ═══════════════════════════════════════════════════════
w("modules/00-core/01-lib-mkservice.nix", '''\
# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-001"
# title: "MkService Helper Library"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [library,helper,mkservice,caddy,sso,sandboxing]
# description: "Reusable service factory: generates systemd sandboxing, Caddy vhosts with SSO, and network namespace support."
# path: "modules/00-core/01-lib-mkservice.nix"
# provides: [my.lib.mkService]
# requires: []
# links:
#   module: modules/00-core/01-lib-mkservice.nix
# source: _meta/00-core/lib-helpers.nix (NIXH-00-COR-001)
# ---
# ---ENDNIXMETA
{ lib, config, ... }:
let
  domain = config.my.configs.identity.domain;
  baseDomain = "nix.${domain}";
in
{
  options.my.lib.mkService = lib.mkOption {
    type = lib.types.functionTo lib.types.attrs;
    internal = true;
    description = "Reusable service factory function.";
  };

  config.my.lib = {
    mkService = { name
                 , port
                 , useSSO ? true
                 , description ? "Managed Service"
                 , readWritePaths ? []
                 , allowNetwork ? true
                 , netns ? null
                 , targetHost ? "127.0.0.1"
                 }:
      let
        host = "${name}.${baseDomain}";
        target = "http://${if netns != null then "10.200.1.2" else targetHost}:${toString port}";
        trustedIPs = "127.0.0.1 100.64.0.0/10";
      in {
        systemd.services."${name}".serviceConfig = {
          Description = lib.mkDefault description;
          ProtectSystem = lib.mkDefault "strict";
          ProtectHome = lib.mkDefault true;
          PrivateTmp = lib.mkDefault true;
          PrivateDevices = lib.mkDefault true;
          NoNewPrivileges = lib.mkDefault true;
          Restart = lib.mkDefault "always";
          ReadWritePaths = lib.mkDefault readWritePaths;
          NetworkNamespacePath = lib.mkIf (netns != null) "/run/netns/${netns}";
          CapabilityBoundingSet = lib.mkIf (!allowNetwork) [];
        };

        services.caddy.virtualHosts."${host}" = {
          extraConfig = ''
            @trusted_network remote_ip ${trustedIPs}
            handle @trusted_network {
              reverse_proxy ${target}
            }
            ${lib.optionalString useSSO "import sso_auth"}
            reverse_proxy ${target}
          '';
        };
      };
  };
}
''')

# ═══════════════════════════════════════════════════════
# 2. DEFAULTS SYSTEM (ABC Tiering Paths, Locale, Security)
# ═══════════════════════════════════════════════════════
w("modules/00-core/02-defaults.nix", '''\
# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-009"
# title: "Global Defaults"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [defaults,paths,locale,security,abc-tiering]
# description: "Shared global defaults: ABC tiering paths, locale, security conventions, network namespaces."
# path: "modules/00-core/02-defaults.nix"
# provides: [my.defaults]
# requires: []
# links:
#   module: modules/00-core/02-defaults.nix
# source: _meta/00-core/defaults.nix (NIXH-00-COR-009)
# ---
# ---ENDNIXMETA
{ lib, ... }:
{
  options.my.defaults = {
    # ── Network ──
    netns = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default network namespace for all services.";
    };
    bindAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Default bind address for all services.";
    };

    # ── Locale ──
    locale = {
      timezone = lib.mkOption { type = lib.types.str; default = "Europe/Berlin"; };
      language = lib.mkOption { type = lib.types.str; default = "de_DE.UTF-8"; };
      dateOrder = lib.mkOption { type = lib.types.enum [ "DMY" "MDY" "YMD" ]; default = "DMY"; };
    };

    # ── OCR ──
    ocr = {
      languages = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "deu" "eng" ]; };
      outputType = lib.mkOption { type = lib.types.enum [ "pdfa" "pdfa-1" "pdfa-2" "pdfa-3" "pdf" "none" ]; default = "pdfa"; };
    };

    # ── Filesystem Prefixes (ABC Tiering) ──
    paths = {
      statePrefix = lib.mkOption { type = lib.types.str; default = "/data/state"; description = "State directory prefix."; };
      mediaRoot = lib.mkOption { type = lib.types.str; default = "/mnt/media"; description = "Media root directory."; };
      downloadsDir = lib.mkOption { type = lib.types.str; default = "/mnt/media/downloads"; };
      fastPoolRoot = lib.mkOption { type = lib.types.str; default = "/mnt/fast-pool"; description = "Fast pool (NVMe/SSD) root."; };
      documentRoot = lib.mkOption { type = lib.types.str; default = "/mnt/documents"; };
      backupRoot = lib.mkOption { type = lib.types.str; default = "/mnt/backup"; };
    };

    # ── Security ──
    security = {
      defaultGroup = lib.mkOption { type = lib.types.str; default = "media"; };
      ssoEnable = lib.mkOption { type = lib.types.bool; default = true; };
    };

    # ── Observability ──
    observability = {
      logLevel = lib.mkOption { type = lib.types.enum [ "DEBUG" "INFO" "WARNING" "ERROR" ]; default = "WARNING"; };
      metricsPortOffset = lib.mkOption { type = lib.types.int; default = 9000; };
    };
  };
}
''')

# ═══════════════════════════════════════════════════════
# 3. PORT REGISTRY
# ═══════════════════════════════════════════════════════
w("modules/00-core/03-ports.nix", '''\
# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-025"
# title: "Port Registry"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [ports,registry,ssot,networking]
# description: "Central port registry with 10k/20k schema mapping and duplicate detection."
# path: "modules/00-core/03-ports.nix"
# provides: [my.ports]
# requires: []
# links:
#   module: modules/00-core/03-ports.nix
# source: _meta/00-core/ports.nix (NIXH-00-COR-025)
# ---
# ---ENDNIXMETA
{ lib, config, ... }:
let
  allPorts = lib.attrValues config.my.ports;
  hasDuplicates = (lib.length (lib.unique allPorts)) != (lib.length allPorts);
in
{
  options.my.ports = lib.mkOption {
    type = lib.types.attrsOf lib.types.port;
    default = {};
    description = "Central port registry.";
  };

  config.my.ports = {
    # ── System & Edge ──
    ssh = 53844;
    edgeHttps = 443;

    # ── 10-Infrastructure ──
    adguard = 10000;
    uptimeKuma = 10001;
    pocketId = 10010;
    homepage = 10082;
    netdata = 10999;
    valkey = 6379;
    olivetin = 10080;
    cockpit = 10090;
    ddnsUpdater = 10100;

    # ── 20-Apps / Media ──
    jellyfin = 20096;
    vaultwarden = 20002;
    n8n = 20017;
    paperless = 20981;
    ollama = 11434;
    sonarr = 20989;
    radarr = 20878;
    lidarr = 20686;
    prowlarr = 20696;
    readarr = 20787;
    sabnzbd = 20080;
    jellyseerr = 25055;
    matrix = 20006;
    audiobookshelf = 20081;
    readeck = 20005;
    scrutiny = 20007;
    miniflux = 20008;
    filebrowser = 20001;
    karakeep = 20003;
    openWebui = 20009;
    monica = 20004;
    linkwarden = 3000;

    # ── IoT & Messaging ──
    zigbee2mqtt = 28080;
    mqtt = 1883;

    # ── Monitoring ──
    gatus = 8080;
    homeAssistant = 8123;
  };

  # SRE Safety: Warn on port collision
  warnings = lib.optional hasDuplicates "⚠️ [SRE-WARNING] Duplicate port assignment in registry!";
}
''')

# ═══════════════════════════════════════════════════════
# 4. REGISTRY (Master Switchboard)
# ═══════════════════════════════════════════════════════
w("modules/00-core/04-registry.nix", '''\
# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-027"
# title: "Service Registry"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-21
# tags: [registry,switchboard,feature-flags,hardware-profiles]
# description: "Master switchboard: declarative toggles for all services, hardware profiles, and networking features."
# path: "modules/00-core/04-registry.nix"
# provides: [my.services, my.profiles]
# requires: []
# links:
#   module: modules/00-core/04-registry.nix
# source: _meta/00-core/registry.nix (NIXH-00-COR-027)
# ---
# ---ENDNIXMETA
{ lib, ... }:
{
  options.my = {
    # ── Service Toggles ──
    services = {
      # Infrastructure
      caddy.enable = lib.mkEnableOption "Caddy edge proxy";
      pocketId.enable = lib.mkEnableOption "Pocket-ID OIDC provider";
      postgresql.enable = lib.mkEnableOption "PostgreSQL database";
      valkey.enable = lib.mkEnableOption "Valkey (Redis fork) cache";
      clamav.enable = lib.mkEnableOption "ClamAV antivirus";
      secretIngest.enable = lib.mkEnableOption "Secret landing zone watcher";
      kernelSlim.enable = lib.mkEnableOption "Kernel slim/hardening";
      configMerger.enable = lib.mkEnableOption "Config merger service";
      mediaStack.enable = lib.mkEnableOption "Media stack layout";
      arrWire.enable = lib.mkEnableOption "ARR API wiring helper";
      backup.enable = lib.mkEnableOption "Restic backup";
      netdata.enable = lib.mkEnableOption "Netdata monitoring";
      scrutiny.enable = lib.mkEnableOption "S.M.A.R.T monitoring";
      uptimeKuma.enable = lib.mkEnableOption "Uptime Kuma";
      aiAgents.enable = lib.mkEnableOption "Ollama + Claude Code";
      semaphore.enable = lib.mkEnableOption "Ansible Semaphore";
      miniflux.enable = lib.mkEnableOption "Miniflux RSS reader";
      linkwarden.enable = lib.mkEnableOption "Linkwarden bookmarks";
      karakeep.enable = lib.mkEnableOption "Karakeep bookmarks";
      matrixConduit.enable = lib.mkEnableOption "Matrix Conduit homeserver";
      monica.enable = lib.mkEnableOption "Monica CRM";
      couchdb.enable = lib.mkEnableOption "CouchDB";
      filebrowser.enable = lib.mkEnableOption "Filebrowser";

      # Hardware profiles
      hardwareProfile = lib.mkOption {
        type = lib.types.enum [ "q958" "generic" ];
        default = "generic";
        description = "Hardware profile selection.";
      };
    };

    # ── Hardware Profiles ──
    profiles = {
      hardware.q958.enable = lib.mkEnableOption "Fujitsu Q958 optimizations (Intel i5-4570T, 16GB RAM)";
      networking = {
        systemd-networkd.enable = lib.mkEnableOption "systemd-networkd for fast boot";
        vpn-confinement.enable = lib.mkEnableOption "VPN network namespace isolation";
        reverseProxy = lib.mkOption {
          type = lib.types.enum [ "caddy" "traefik" "nginx" "none" ];
          default = "caddy";
          description = "Reverse proxy selection.";
        };
      };
    };

    # ── Identity (central SSoT) ──
    configs = {
      identity = {
        host = lib.mkOption { type = lib.types.str; default = "nixhome"; description = "Hostname."; };
        user = lib.mkOption { type = lib.types.str; default = "moritz"; description = "Primary user."; };
        domain = lib.mkOption { type = lib.types.str; default = "m7c5.de"; description = "Primary domain."; };
        subdomain = lib.mkOption { type = lib.types.str; default = "nix"; description = "Subdomain."; };
        email = lib.mkOption { type = lib.types.str; default = "admin@m7c5.de"; description = "Admin email."; };
      };
      server = {
        lanIP = lib.mkOption { type = lib.types.str; default = "10.254.0.1"; description = "LAN IP address."; };
        tailscaleIP = lib.mkOption { type = lib.types.str; default = "100.64.3.155"; description = "Tailscale IP."; };
      };
      network = {
        lanCidrs = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "10.254.0.0/24" "192.168.1.0/24" ]; };
        tailnetCidrs = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "100.64.0.0/10" ]; };
      };
      paths = {
        mediaLibrary = lib.mkOption { type = lib.types.str; default = "/mnt/media"; };
        storagePool = lib.mkOption { type = lib.types.str; default = "/mnt/fast-pool"; };
        stateDir = lib.mkOption { type = lib.types.str; default = "/data/state"; };
      };
      bastelmodus = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Workshop mode — disables firewall for testing.";
      };
      hardware = {
        cpuType = lib.mkOption { type = lib.types.enum [ "intel" "amd" ]; default = "intel"; };
        ramGB = lib.mkOption { type = lib.types.int; default = 16; };
        intelGpu = lib.mkOption { type = lib.types.bool; default = true; description = "Intel iGPU available."; };
      };
      vpn.privado = {
        publicKey = lib.mkOption { type = lib.types.str; default = ""; };
        endpoint = lib.mkOption { type = lib.types.str; default = ""; };
        address = lib.mkOption { type = lib.types.str; default = ""; };
        dns = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
      };
    };
  };
}
''')

# ═══════════════════════════════════════════════════════
# 5. SYSTEM STABILITY (EFI cleanup, drift detection, emergency)
# ═══════════════════════════════════════════════════════
w("modules/00-core/05-system-stability.nix", '''\
# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-034"
# title: "System Stability"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [stability,maintenance,efi,drift-detection,emergency]
# description: "Proactive maintenance: EFI boot entry cleanup, config drift detection, emergency recovery info."
# path: "modules/00-core/05-system-stability.nix"
# provides: [my.stability]
# requires: [00-core]
# links:
#   module: modules/00-core/05-system-stability.nix
# source: _meta/00-core/system-stability.nix (NIXH-00-COR-034)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
{
  options.my.stability.enable = lib.mkEnableOption "System stability services";

  config = lib.mkIf config.my.stability.enable {
    # ── EFI Boot Entry Cleanup ──
    system.activationScripts.cleanEfiEntries = {
      text = ''
        echo "🧹 Cleaning orphaned EFI boot entries..."
        ${pkgs.efibootmgr}/bin/efibootmgr | grep "Boot[0-9]" | grep -vE "systemd-boot|NixOS|Linux|USB|Hard Drive|Network" | \\
          ${pkgs.gawk}/bin/awk '{print $1}' | ${pkgs.gnused}/bin/sed 's/Boot//;s/\\*//' | \\
          xargs -I{} ${pkgs.efibootmgr}/bin/efibootmgr -b {} -B 2>/dev/null || true
      '';
    };

    # ── Config Drift Detector ──
    systemd.services.config-drift-detector = {
      description = "Detect configuration drift";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        USER_CONFIG='/var/lib/nixhome/user-config.json'
        if [ -f "$USER_CONFIG" ] && [ "$(cat "$USER_CONFIG")" != "{}" ]; then
          echo "⚠️ NOTICE: System uses imperative settings."
        fi
      '';
    };

    # ── Emergency Recovery Info ──
    systemd.services.nixhome-emergency = {
      description = "NixOS Emergency Recovery Info";
      serviceConfig = {
        Type = "oneshot";
        StandardOutput = "tty";
        TTYPath = "/dev/tty1";
      };
      script = ''
        echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' > /dev/tty1
        echo '🚨 NIXHOME SETUP FAILED' > /dev/tty1
        echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' > /dev/tty1
        echo 'Boot into previous generation: nixos-rebuild switch --rollback' > /dev/tty1
      '';
    };
  };
}
''')

# ═══════════════════════════════════════════════════════
# 6. CONFIG MERGER (Nix defaults + user JSON)
# ═══════════════════════════════════════════════════════
w("modules/00-core/06-config-merger.nix", '''\
# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-007"
# title: "Config Merger"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [config,merger,json,runtime,overrides]
# description: "Dynamic bridge between NixOS declarations and user-managed JSON overrides for runtime services."
# path: "modules/00-core/06-config-merger.nix"
# provides: [my.configMerger]
# requires: [00-core]
# links:
#   module: modules/00-core/06-config-merger.nix
# source: _meta/00-core/config-merger.nix (NIXH-00-COR-007)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
  runDir = "/run/nixhome";
  userConfig = "/var/lib/nixhome/user-config.json";
  finalConfig = "${runDir}/config.json";

  nixDefaults = pkgs.writeText "nix-defaults.json" (builtins.toJSON {
    domain = config.my.configs.identity.domain;
    email = config.my.configs.identity.email;
    lanIP = config.my.configs.server.lanIP;
    hostName = config.my.configs.identity.host;
    bastelmodus = config.my.configs.bastelmodus;
  });

  mergerScript = pkgs.writeShellScript "nixhome-config-merger" ''
    set -euo pipefail
    mkdir -p ${runDir}
    if [ ! -f "${userConfig}" ]; then
      echo "{}" > "${userConfig}"
      chown root:root "${userConfig}"
      chmod 644 "${userConfig}"
    fi
    ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "${nixDefaults}" "${userConfig}" > "${finalConfig}.tmp"
    mv "${finalConfig}.tmp" "${finalConfig}"
    chmod 644 "${finalConfig}"
  '';
in
{
  options.my.configMerger.enable = lib.mkEnableOption "Config merger service";

  config = lib.mkIf config.my.configMerger.enable {
    systemd.services.nixhome-config-merger = {
      description = "Merge Nix Defaults with User JSON Config";
      before = [ "caddy.service" "pocket-id.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = mergerScript;
      };
    };

    environment.systemPackages = [ pkgs.jq ];
    systemd.tmpfiles.rules = [ "d /var/lib/nixhome 0755 root root -" ];
  };
}
''')

# ═══════════════════════════════════════════════════════
# 7. SHELL PREMIUM (Fastfetch, aliases, service checks)
# ═══════════════════════════════════════════════════════
w("modules/00-core/07-shell-premium.nix", '''\
# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-029"
# title: "Shell Premium"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [shell,aliases,fastfetch,motd,service-check]
# description: "Advanced shell: fastfetch MOTD, service status checks, power-user aliases (nsw, ntest, etc.)."
# path: "modules/00-core/07-shell-premium.nix"
# provides: [my.shell.premium]
# requires: [00-core]
# links:
#   module: modules/00-core/07-shell-premium.nix
# source: _meta/00-core/shell-premium.nix (NIXH-00-COR-029)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
  serviceStatusScript = pkgs.writeShellScriptBin "check-services" ''
    #!/usr/bin/env bash
    CRITICAL_SERVICES=("sshd:SSH" "caddy:Caddy" "tailscaled:Tailscale" "fail2ban:Fail2ban")
    echo -e "\\n🔧 Service Status:\\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    for entry in "''${CRITICAL_SERVICES[@]}"; do
      service="''${entry%%:*}"; label="''${entry##*:}"
      if systemctl is-active --quiet "$service"; then echo "  ✅ $label"; else echo "  ❌ $label (ERROR!)"; fi
    done
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  '';
in
{
  options.my.shell.premium.enable = lib.mkEnableOption "Advanced Shell Features (Fastfetch, Service Checks)";

  config = lib.mkIf config.my.shell.premium.enable {
    programs.bash.shellAliases = {
      nsw = "sudo nixos-rebuild switch";
      ntest = "sudo nixos-rebuild test";
      ndry = "sudo nixos-rebuild dry-run";
      nboot = "sudo nixos-rebuild boot";
      nup = "nix flake update";
      nclean = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5 && sudo nix-store --gc";
      nopt = "sudo nix-store --optimise";
      ngen = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
      ncfg = "cd /etc/nixos";
      ngit = "cd /etc/nixos && git status -sb";
      nlog = "journalctl -xef";
      ls = "${pkgs.eza}/bin/eza --icons";
      ll = "${pkgs.eza}/bin/eza -la --icons --git";
      tree = "${pkgs.eza}/bin/eza --tree --icons";
      cat = "${pkgs.bat}/bin/bat --paging=never";
      top = "${pkgs.htop}/bin/htop";
      df = "${pkgs.duf}/bin/duf";
      du = "${pkgs.dust}/bin/dust";
      services = "${serviceStatusScript}/bin/check-services";
      ports = "sudo ss -tulpn";
      gs = "git status -sb";
      ga = "git add";
      gc = "git commit -m";
      gp = "git push";
      gl = "git log --oneline --graph --decorate --all -n 10";
    };

    environment.systemPackages = with pkgs; [
      bat eza ripgrep fd duf dust htop nix-tree nix-diff nixfmt-classic nix-output-monitor
      fastfetch micro git curl wget tree unzip file lsof ncdu serviceStatusScript
    ];
  };
}
''')

# ═══════════════════════════════════════════════════════
# 8. TTY INFO (IP display on console)
# ═══════════════════════════════════════════════════════
w("modules/00-core/08-tty-info.nix", '''\
# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-036"
# title: "TTY Info"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [tty,console,ip-info,observability]
# description: "Display IP addresses and SSH info on physical console (TTY1)."
# path: "modules/00-core/08-tty-info.nix"
# provides: [my.ttyInfo]
# requires: [00-core]
# links:
#   module: modules/00-core/08-tty-info.nix
# source: _meta/00-core/tty-info.nix (NIXH-00-COR-036)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
{
  options.my.ttyInfo.enable = lib.mkEnableOption "Display IP info on TTY1";

  config = lib.mkIf config.my.ttyInfo.enable {
    systemd.services.tty-ip-info = {
      description = "Display IP Address on TTY1";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StandardOutput = "tty";
        TTYPath = "/dev/tty1";
      };
      script = ''
        sleep 2
        echo -e "\\n\\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\\033[0m"
        echo -e "\\033[1;32m🌐 NIXHOME SYSTEM STATUS\\033[0m"
        echo -e "\\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\\033[0m"
        echo -e "\\n\\033[1;34m📍 IPv4 Addresses:\\033[0m"
        ${pkgs.iproute2}/bin/ip -4 -o addr show | ${pkgs.gnugrep}/bin/grep -v 'lo' | ${pkgs.gawk}/bin/awk '{print "   • " $2 ": " $4}' | ${pkgs.gnused}/bin/sed 's|/[0-9]*||'
        echo -e "\\n\\033[1;34m🔗 Local URLs:\\033[0m"
        echo -e "   • http://nixhome.local"
        echo -e "   • http://$(hostname).local"
        echo -e "\\n\\033[1;33m🛠  SSH Access:\\033[0m"
        echo -e "   ssh ${config.my.configs.identity.user}@$(hostname).local -p ${toString config.my.ports.ssh}"
        echo -e "\\n\\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\\033[0m\\n"
      '';
    };
  };
}
''')

# ═══════════════════════════════════════════════════════
# 9. BACKUP (Restic with cloud sync)
# ═══════════════════════════════════════════════════════
w("modules/00-core/09-backup.nix", '''\
# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-004"
# title: "Backup (Restic)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [backup,restic,cloud-sync,integrity-check]
# description: "Restic backup with automated integrity checks, max compression, and cloud sync via rclone."
# path: "modules/00-core/09-backup.nix"
# provides: [my.backup]
# requires: [00-core, 30-storage]
# links:
#   module: modules/00-core/09-backup.nix
# source: _meta/00-core/backup.nix (NIXH-00-COR-004)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
  cfg = config.my.backup;
  localRepo = "${cfg.repo}/.restic-vault";
in
{
  options.my.backup = {
    enable = lib.mkEnableOption "Restic backup with cloud sync";
    repo = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/backup";
      description = "Local backup repository path.";
    };
    passwordFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/secrets/restic-password";
      description = "Path to restic password file.";
    };
    maxSizeGB = lib.mkOption {
      type = lib.types.int;
      default = 15;
      description = "Maximum backup size in GB.";
    };
    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "/data/state" "/data/metadata" "/etc/nixos" ];
      description = "Paths to back up.";
    };
    remoteName = lib.mkOption {
      type = lib.types.str;
      default = "cloud-backup";
      description = "Rclone remote name for cloud sync.";
    };
    remotePath = lib.mkOption {
      type = lib.types.str;
      default = "nixhome-vault";
      description = "Rclone remote path.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.restic.backups.daily = {
      initialize = true;
      repository = localRepo;
      passwordFile = cfg.passwordFile;
      paths = cfg.paths;
      exclude = [ "**/.cache" "**/tmp" "**/node_modules" ];
      createWrapper = true;
      runCheck = true;
      checkOpts = [ "--with-cache" ];
      extraOptions = [ "--exclude-caches" "--compression=max" ];
      inhibitsSleep = true;
      timerConfig = {
        OnCalendar = "02:00";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
      pruneOpts = [ "--keep-daily 7" "--keep-weekly 4" "--keep-monthly 6" ];
    };

    systemd.services.restic-cloud-sync = {
      description = "Sync Restic Vault to Cloud";
      after = [ "restic-backups-daily.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.rclone}/bin/rclone sync ${localRepo} ${cfg.remoteName}:${cfg.remotePath} --bwlimit 5M";
      };
    };

    environment.systemPackages = with pkgs; [ restic rclone ];
  };
}
''')

# ═══════════════════════════════════════════════════════
# 10. NIX TUNING (binary-only, auto-gc)
# ═══════════════════════════════════════════════════════
w("modules/00-core/10-nix-tuning.nix", '''\
# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-024"
# title: "Nix Tuning"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [nix,tuning,binary-cache,gc,auto-optimise]
# description: "Binary cache enforcement, nix-daemon tuning, auto GC, and store optimization."
# path: "modules/00-core/10-nix-tuning.nix"
# provides: [my.nixTuning]
# requires: []
# links:
#   module: modules/00-core/10-nix-tuning.nix
# source: _meta/00-core/nix-tuning.nix (NIXH-00-COR-024)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
{
  options.my.nixTuning.enable = lib.mkEnableOption "Nix tuning (binary-only, auto-gc)";

  config = lib.mkIf config.my.nixTuning.enable {
    nix.settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      max-jobs = lib.mkForce 0;
      connect-timeout = 5;
      builders-use-substitutes = true;
      auto-optimise-store = true;
      narinfo-cache-negative-ttl = 0;
      timeout = 1800;
      experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" "cgroups" ];
      sandbox = true;
      trusted-users = [ "root" "@wheel" ];
    };

    nix.daemonCPUSchedPolicy = "idle";
    nix.daemonIOSchedClass = "idle";

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
      persistent = true;
    };

    environment.systemPackages = with pkgs; [
      cachix nix-tree nix-diff nix-output-monitor nixfmt-classic
    ];
  };
}
''')

print("\n✅ Phase 1 complete: 10 core modules written.")
