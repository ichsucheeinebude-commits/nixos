# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-011"
# title: "Tailscale VPN"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [network,vpn,tailscale,zerotouch,sops]
# description: "Declarative VPN with autoconnect pattern and SOPS-nix secret integration."
# path: "modules/10-network/21-tailscale.nix"
# provides: [my.network.tailscale]
# requires: [my.core.secrets]
# links:
#   adr: docs/adr/ADR-10-network.md
#   guide: docs/guides/10-network.md
#   module: modules/10-network/21-tailscale.nix
#   upstream: https://github.com/tailscale/tailscale
#   wiki: https://nixos.wiki/wiki/Tailscale
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Tailscale bietet Zero-Config WireGuard VPN. Das Problem: Nach einem Neustart
# muss manuell `tailscale up` mit Auth-Key ausgeführt werden.
#
# ### Entscheidung
#
# **Auto-Connect Pattern:**
# 1.  **One-Shot Auth Service** — Prüft Status nach Boot, loggt sich automatisch ein.
# 2.  **SOPS Integration** — Auth-Key aus verschlüsselter secrets.yaml.
# 3.  **High Priority** — OOMScoreAdjust = -1000 (niemals gekillt).
# 4.  **Caddy Cert Permission** — PermitCertUid für ACME-Zertifikate.
#
# ### SRE-Standards
#
# - Firewall bleibt geschlossen (openFirewall = false).
# - Client-Modus nur (kein Exit-Node, kein Subnet-Router).
# - SSH und DNS-Akzeptanz aktiviert.
# ─── End KB Nuggets ───

{ config, lib, pkgs, ... }:

{
  options.my.network.tailscale = {
    enable = lib.mkEnableOption "Tailscale VPN with auto-connect";
    authKeySecret = lib.mkOption {
      type = lib.types.str;
      default = "/run/secrets/tailscale_token";
      description = "Path to SOPS secret containing the Tailscale auth key.";
    };
  };

  config = lib.mkIf config.my.network.tailscale.enable {
    services.tailscale = {
      enable = true;
      openFirewall = false;
      useRoutingFeatures = "client";
      extraUpFlags = [ "--ssh" "--accept-dns=true" "--accept-routes=true" ];
      permitCertUid = config.services.caddy.user or "caddy";
    };

    # ── Auto-Connect One-Shot ──
    systemd.services.tailscale-autoconnect = {
      description = "Automatic Tailscale Login";
      after = [ "tailscaled.service" "network-online.target" ];
      wants = [ "tailscaled.service" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "tailscale-auth" ''
          sleep 2
          status=$(${pkgs.tailscale}/bin/tailscale status --json | ${pkgs.jq}/bin/jq -r .BackendState)
          if [ "$status" = "NeedsLogin" ] || [ "$status" = "Stopped" ]; then
            ${pkgs.tailscale}/bin/tailscale up --authkey="$(cat ${config.my.network.tailscale.authKeySecret})"
          fi
        '';
      };
    };

    # ── Daemon Priority ──
    systemd.services.tailscaled = {
      stopIfChanged = false;
      serviceConfig = {
        Restart = "always";
        RestartSec = "2s";
        OOMScoreAdjust = -1000;
      };
    };
  };
}
