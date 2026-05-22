# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-000"
# title: "App Factory — Declarative Web App Generator"
# type: module
# status: draft
# complexity: 4
# reviewed: 2026-05-22
# tags: [apps,factory,caddy,systemd,web-apps,sso]
# description: "Single factory function that generates lightweight web apps with shared patterns: Caddy reverse proxy, systemd hardening, SSO authentication, state management."
# path: "modules/60-apps/60-mkapp-factory.nix"
# provides: [my.apps.mkapp-factory]
# requires: [my.core.identity, my.network.caddy]
# links:
#   adr: docs/adr/ADR-60-apps.md
#   guide: docs/guides/60-apps.md
#   module: modules/60-apps/60-mkapp-factory.nix
# sources: [nixflix, nixarr patterns adapted for web apps]
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Vorher: ~10 kleine App-Module (<100 Lines), 80% Copy-Paste (Caddy vhost,
# systemd hardening, SSO import, state management).
# ### Entscheidung
#
# mkAppFactory: Eine Funktion generiert alle leichten Web-Apps mit:
# - Caddy reverse proxy mit vhost
# - systemd hardening (ProtectSystem, ProtectHome, NoNewPrivileges)
# - SSO authentication via pocket-id
# - State management in /data/.state/apps/<name>
# - Reduziert ~500 Lines Redundanz → ~150 Lines
# ─── End KB Nuggets ───

{ config, lib, pkgs, ... }:

let
  cfg = config.my.apps.mkapp-factory;
  identityCfg = config.my.core.identity;

  # ── Factory Function ──
  mkWebApp = {
    name,
    serviceName,
    port,
    subdomain,
    enable ? true,
    group ? null,
    dataDir ? "/var/lib/${serviceName}",
    stateDir ? "/data/.state/apps/${serviceName}",
    readOnlyPaths ? [],
    readWritePaths ? [],
    extraServiceConfig ? {},
    extraCaddyConfig ? {},
    ssoEnable ? true,
    openFirewall ? false,
  }:
    let
      domain = identityCfg.domain or "local";
      serverName = "${subdomain}.${domain}";
      caddyBase = ''
        reverse_proxy 127.0.0.1:${toString port}
      '';
      caddySSO = if ssoEnable then ''
        import sso_auth
      '' else "";
      caddyExtra = lib.concatStringsSep "\n" (lib.attrValues extraCaddyConfig);
    in
    {
      config = lib.mkIf enable {
        # ── NixOS Service ──
        "services.${serviceName}" = lib.mkMerge [
          { enable = true; }
          (if serviceName == "matrix-conduit" then {
            port = port;
          } else if serviceName == "readeck" then {
            listenPort = port;
          } else if serviceName == "miniflux" then {
            listenPort = "[::1]:${toString port}";
          } else if serviceName == "karakeep" then {
            port = port;
          } else if serviceName == "linkding" then {
            port = port;
          } else {
            port = port;
          })
          (lib.optionalAttrs (group != null) { inherit group; })
        ];

        # ── Caddy Reverse Proxy ──
        "services.caddy.virtualHosts.\"${serverName}\".extraConfig" = ''
          ${caddyBase}
          ${caddySSO}
          ${caddyExtra}
        '';

        # ── Systemd Hardening ──
        "systemd.services.${serviceName}.serviceConfig" = lib.mkMerge [
          {
            ProtectSystem = "strict";
            ProtectHome = true;
            NoNewPrivileges = true;
            PrivateTmp = true;
            ReadWritePaths = [
              dataDir
              stateDir
            ] ++ readWritePaths;
            ReadOnlyPaths = readOnlyPaths;
          }
          extraServiceConfig
        ];

        # ── State Directory ──
        systemd.tmpfiles.rules = [
          "d ${stateDir} 0750 ${serviceName} ${if group != null then group else "root"} -"
        ];

        # ── Firewall ──
        networking.firewall.allowedTCPPorts = lib.mkIf openFirewall [ port ];
      };
    };

in
{
  options.my.apps.mkapp-factory = {
    enable = lib.mkEnableOption "App Factory: generate lightweight web apps from shared patterns";

    # ── Matrix Conduit ──
    matrix-conduit = {
      enable = lib.mkOption { type = lib.types.bool; default = false; };
      subdomain = lib.mkOption { type = lib.types.str; default = "chat"; };
      port = lib.mkOption { type = lib.types.port; default = 61616; };
    };

    # ── Readeck ──
    readeck = {
      enable = lib.mkOption { type = lib.types.bool; default = false; };
      subdomain = lib.mkOption { type = lib.types.str; default = "read"; };
      port = lib.mkOption { type = lib.types.port; default = 9090; };
    };

    # ── Miniflux ──
    miniflux = {
      enable = lib.mkOption { type = lib.types.bool; default = false; };
      subdomain = lib.mkOption { type = lib.types.str; default = "rss"; };
      port = lib.mkOption { type = lib.types.port; default = 8082; };
    };

    # ── Linkding ──
    linkding = {
      enable = lib.mkOption { type = lib.types.bool; default = false; };
      subdomain = lib.mkOption { type = lib.types.str; default = "links"; };
      port = lib.mkOption { type = lib.types.port; default = 9090; };
    };

    # ── Karakeep ──
    karakeep = {
      enable = lib.mkOption { type = lib.types.bool; default = false; };
      subdomain = lib.mkOption { type = lib.types.str; default = "karakeep"; };
      port = lib.mkOption { type = lib.types.port; default = 3000; };
    };

    # ── Expose Factory ──
    lib.mkWebApp = lib.mkOption {
      type = lib.types.functionTo lib.types.attrs;
      default = mkWebApp;
      visible = false;
      description = "Factory function to create custom web apps.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf cfg.matrix-conduit.enable (mkWebApp {
      name = "matrix-conduit";
      serviceName = "matrix-conduit";
      port = cfg.matrix-conduit.port;
      subdomain = cfg.matrix-conduit.subdomain;
      enable = cfg.matrix-conduit.enable;
    }).config)
    (lib.mkIf cfg.readeck.enable (mkWebApp {
      name = "readeck";
      serviceName = "readeck";
      port = cfg.readeck.port;
      subdomain = cfg.readeck.subdomain;
      enable = cfg.readeck.enable;
    }).config)
    (lib.mkIf cfg.miniflux.enable (mkWebApp {
      name = "miniflux";
      serviceName = "miniflux";
      port = cfg.miniflux.port;
      subdomain = cfg.miniflux.subdomain;
      enable = cfg.miniflux.enable;
    }).config)
    (lib.mkIf cfg.linkding.enable (mkWebApp {
      name = "linkding";
      serviceName = "linkding";
      port = cfg.linkding.port;
      subdomain = cfg.linkding.subdomain;
      enable = cfg.linkding.enable;
    }).config)
    (lib.mkIf cfg.karakeep.enable (mkWebApp {
      name = "karakeep";
      serviceName = "karakeep";
      port = cfg.karakeep.port;
      subdomain = cfg.karakeep.subdomain;
      enable = cfg.karakeep.enable;
    }).config)
  ]);
}
