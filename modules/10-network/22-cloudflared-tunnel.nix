# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-012"
# title: "Cloudflare Tunnel"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [network,ingress,cloudflare,tunnel,zero-trust]
# description: "Secure Ingress bridge using Cloudflare Tunnels for zero-port-forwarding connectivity."
# path: "modules/10-network/22-cloudflared-tunnel.nix"
# provides: [my.network.cloudflared]
# requires: [my.network.caddy, my.core.identity]
# links:
#   adr: docs/adr/ADR-10-network.md
#   guide: docs/guides/10-network.md
#   module: modules/10-network/22-cloudflared-tunnel.nix
#   upstream: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Herkömmliche Port-Forwarding-Lösungen exponieren den Server direkt im
# öffentlichen Internet. Cloudflare Tunnels erstellen eine ausgehende
# Verbindung zum Cloudflare-Edge — keine offenen Ports, keine Firewall-Regeln.
#
# ### Entscheidung
#
# **Cloudflared Tunnel Pattern:**
# 1.  **Outbound-Only** — Nur ausgehende Verbindung zu Cloudflare (kein offener Port).
# 2.  **Wildcard-Ingress** — `*.nix.<domain>` wird zum lokalen Proxy geroutet.
# 3.  **Credential File** — Tunnel-Auth über SOPS-geschützte Credentials.
# 4.  **Origin Hardening** — HTTP/2, Keep-Alive, TLS-Verification.
#
# ### SRE-Standards
#
# - Credentials müssen vor Service-Start existieren (preStart check).
# - TunnelID muss gesetzt sein (assertion).
# - Default: 404 für nicht gemappte Hosts.
# - Strict Sandboxing: ProtectSystem, NoNewPrivileges, CapabilityBoundingSet.
# ─── End KB Nuggets ───

{ config, lib, ... }:

let
  domain = config.my.core.identity.domain;
  subdomain = config.my.core.identity.subdomain or "nix";
in
{
  options.my.network.cloudflared = {
    enable = lib.mkEnableOption "Cloudflare Tunnel for zero-port-forwarding ingress";
    tunnelId = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Cloudflare Tunnel ID (from dashboard).";
    };
    credentialsFile = lib.mkOption {
      type = lib.types.path;
      default = "/run/secrets/cloudflared_credentials.json";
      description = "Path to SOPS secret containing tunnel credentials.";
    };
    wildcardPrefix = lib.mkOption {
      type = lib.types.str;
      default = "*";
      description = "Wildcard DNS prefix for tunnel ingress.";
    };
    proxyUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://127.0.0.1:443";
      description = "Local proxy URL to forward traffic to.";
    };
  };

  config = lib.mkIf config.my.network.cloudflared.enable {
    assertions = [
      {
        assertion = config.my.network.cloudflared.tunnelId != "";
        message = "cloudflared: tunnelId must be set.";
      }
    ];

    services.cloudflared = {
      enable = true;
      tunnels.${config.my.network.cloudflared.tunnelId} = {
        credentialsFile = config.my.network.cloudflared.credentialsFile;
        ingress = {
          "${config.my.network.cloudflared.wildcardPrefix}.${subdomain}.${domain}" = {
            service = config.my.network.cloudflared.proxyUrl;
            originRequest = {
              noTLSVerify = false;
              http2Origin = true;
              keepAliveConnections = 8;
            };
          };
          "_" = "http_status:404";
        };
      };
    };

    # ── Sandboxing ──
    systemd.services.cloudflared.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
      OOMScoreAdjust = -500;
    };
  };
}
