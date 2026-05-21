# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-004"
# title: "Caddy Reverse Proxy"
# type: module
# status: draft
# complexity: 4
# reviewed: 2026-05-21
# tags: [network,caddy,reverse-proxy,ingress,https,tls,forward-auth]
# description: "Caddy M1 Abrams reverse proxy with full option interface from Caddy Encyclopedia."
# path: "modules/10-network/15-caddy.nix"
# provides: [my.network.caddy]
# requires: [10-network]
# links:
#   adr: docs/adr/ADR-15-caddy.md
#   guide: docs/guides/15-caddy.md
#   module: modules/10-network/15-caddy.nix
# source: guides/GUIDE-Caddy-M1-Abrams.md
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
let
  cfg = config.my.network.caddy;
in
{
  options.my.network.caddy = {
    enable = lib.mkEnableOption "Caddy M1 Abrams reverse proxy with automatic HTTPS";

    # ── Network ──
    email = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Email address for ACME registration.";
    };
    listenPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [ 80 443 ];
      description = "Ports Caddy listens on.";
    };

    # ── TLS ──
    minTlsVersion = lib.mkOption {
      type = lib.types.enum [ "1.2" "1.3" ];
      default = "1.2";
      description = "Minimum TLS version.";
    };
    tlsCurves = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "x25519" "secp256r1" "secp384r1" ];
      description = "TLS elliptic curves.";
    };

    # ── DNS Challenge ──
    dnsChallenge = lib.mkOption {
      type = lib.types.enum [ "none" "cloudflare" "route53" "hetzner" "ovh" ];
      default = "none";
      description = "DNS-01 challenge provider for wildcard certificates.";
    };
    dnsApiTokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to file containing DNS provider API token (via SOPS).";
    };

    # ── Forward Auth ──
    forwardAuthUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Forward authentication URL (e.g., PocketID OIDC endpoint).";
    };
    forwardAuthUri = lib.mkOption {
      type = lib.types.str;
      default = "/api/oidc/auth";
      description = "URI path for forward auth requests.";
    };

    # ── API ──
    apiEnabled = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Caddy admin API on localhost:2019.";
    };
    apiListen = lib.mkOption {
      type = lib.types.str;
      default = "localhost:2019";
      description = "Admin API listen address.";
    };

    # ── Logging ──
    logEnabled = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable structured access logging.";
    };
    logFormat = lib.mkOption {
      type = lib.types.enum [ "json" "console" ];
      default = "json";
      description = "Log format.";
    };
    logLevel = lib.mkOption {
      type = lib.types.enum [ "DEBUG" "INFO" "WARN" "ERROR" ];
      default = "INFO";
      description = "Log level.";
    };

    # ── Metrics ──
    metricsEnabled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Prometheus metrics endpoint.";
    };
    metricsPath = lib.mkOption {
      type = lib.types.str;
      default = "/metrics";
      description = "Prometheus metrics endpoint path.";
    };

    # ── Virtual Hosts ──
    vhosts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          hostname = lib.mkOption { type = lib.types.str; description = "Hostname for this vhost."; };
          port = lib.mkOption { type = lib.types.nullOr lib.types.port; default = null; description = "Backend port."; };
          upstream = lib.mkOption { type = lib.types.str; default = "localhost"; description = "Backend upstream address."; };
          forwardAuth = lib.mkOption { type = lib.types.bool; default = true; description = "Enable forward auth for this vhost."; };
          extraConfig = lib.mkOption { type = lib.types.str; default = ""; description = "Additional Caddyfile directives."; };
        };
      });
      default = {};
      description = "Virtual hosts to proxy.";
    };

    # ── Extra Config ──
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional raw Caddyfile content.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      email = lib.mkIf (cfg.email != null) cfg.email;

      virtualHosts = lib.mapAttrs' (name: vhost:
        let
          upstreamUrl = if vhost.port != null
            then "http://${vhost.upstream}:${toString vhost.port}"
            else "http://${vhost.upstream}";
          authBlock = if vhost.forwardAuth && cfg.forwardAuthUrl != null
            then ''
              forward_auth ${cfg.forwardAuthUrl} {
                uri ${cfg.forwardAuthUri}
              }
            ''
            else "";
        in
        lib.nameValuePair vhost.hostname {
          extraConfig = ''
            reverse_proxy ${upstreamUrl}
            ${authBlock}
            ${vhost.extraConfig}
          '';
        }
      ) cfg.vhosts;
    };

    # TLS hardening
    security.acme = {
      defaults.email = lib.mkIf (cfg.email != null) cfg.email;
      acceptTerms = cfg.email != null;
    };

    # Admin API
    systemd.services.caddy.environment = {
      CADDY_ADMIN = lib.mkIf cfg.apiEnabled cfg.apiListen;
    };

    # DNS challenge environment
    systemd.services.caddy.environment = {
      CF_API_TOKEN_FILE = lib.mkIf (cfg.dnsChallenge == "cloudflare") cfg.dnsApiTokenFile;
    };

    # ── Systemd Hardening ──
    systemd.services.caddy.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
    };
  };
}
