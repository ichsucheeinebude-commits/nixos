# ---NIXMETA
# ---
# domain: 80
# id: "NIXH-80-MON-000"
# title: "Monitoring Services Factory — Netdata, Scrutiny, Uptime-Kuma"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [monitoring,factory,caddy,systemd,netdata,scrutiny,uptime-kuma]
# description: "Unified monitoring services module with shared Caddy reverse proxy, systemd hardening, and SSO patterns. Consolidated 3 small modules."
# path: "modules/80-monitoring/80-monitoring-services.nix"
# provides: [my.monitoring.netdata, my.monitoring.scrutiny, my.monitoring.uptimeKuma]
# requires: [my.core.identity, my.network.caddy]
# links:
#   adr: docs/adr/ADR-80-monitoring.md
#   guide: docs/guides/80-monitoring.md
#   module: modules/80-monitoring/80-monitoring-services.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### 📊 Netdata: Real-Time System Monitoring
#
# Echtzeit-Metriken für CPU, RAM, Disk, Network — alles im Browser.
# - **Dienst:** \`services.netdata.enable = true;\`
# - **Nugget:** Caddy vhost mit SSO für sicheren Zugriff.
#
# ### 💾 Scrutiny: SMART Disk Health Monitoring
#
# Automatische SMART-Daten-Erfassung und Health-Checks.
# - **Dienst:** \`services.scrutiny.enable = true;\`
# - **Nugget:** Kombiniert mit \`services.smartd.enable = true\` für proactive Alerts.
#
# ### 🟢 Uptime-Kuma: Service Availability Monitoring
#
# Monitoriert Verfügbarkeit aller Services und sendet Alerts.
# - **Dienst:** \`services.uptime-kuma.enable = true;\`
# - **Nugget:** Subdomain \`status.\${domain}\` für öffentlichen Status-Check.
# ─── End KB Nuggets ───

{ config, lib, pkgs, ... }:

let
  cfg = config.my.monitoring;
  identityCfg = config.my.core.identity;
  domain = identityCfg.domain or "local";

  # ── Factory Function ──
  mkMonitorService = {
    name,
    serviceName,
    subdomain,
    port,
    enable ? true,
    extraServiceConfig ? {},
    extraCaddyConfig ? "",
    extraSystemdConfig ? {},
    smartdEnable ? false,
  }: {
    config = lib.mkIf enable {
      # ── NixOS Service ──
      "services.${serviceName}" = lib.mkMerge [
        { enable = true; }
        extraServiceConfig
      ];

      # ── Smartd (for Scrutiny) ──
      services.smartd.enable = smartdEnable;

      # ── Caddy Reverse Proxy ──
      services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString port}
        import sso_auth
        ${extraCaddyConfig}
      '';

      # ── Systemd Hardening ──
      systemd.services."${serviceName}".serviceConfig = lib.mkMerge [
        {
          ProtectSystem = "strict";
          ProtectHome = true;
          NoNewPrivileges = true;
          PrivateTmp = true;
        }
        extraSystemdConfig
      ];
    };
  };

in
{
  options.my.monitoring = {
    # ── Netdata ──
    netdata = {
      enable = lib.mkOption { type = lib.types.bool; default = false; };
      port = lib.mkOption { type = lib.types.port; default = 19999; };
      subdomain = lib.mkOption { type = lib.types.str; default = "netdata"; };
    };

    # ── Scrutiny ──
    scrutiny = {
      enable = lib.mkOption { type = lib.types.bool; default = false; };
      port = lib.mkOption { type = lib.types.port; default = 8090; };
      subdomain = lib.mkOption { type = lib.types.str; default = "scrutiny"; };
    };

    # ── Uptime-Kuma ──
    uptimeKuma = {
      enable = lib.mkOption { type = lib.types.bool; default = false; };
      port = lib.mkOption { type = lib.types.port; default = 3002; };
      subdomain = lib.mkOption { type = lib.types.str; default = "status"; };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.netdata.enable (mkMonitorService {
      name = "netdata";
      serviceName = "netdata";
      subdomain = cfg.netdata.subdomain;
      port = cfg.netdata.port;
      enable = cfg.netdata.enable;
      extraServiceConfig = {};
      extraSystemdConfig = {
        ProtectSystem = lib.mkForce "full";
      };
    }).config)

    (lib.mkIf cfg.scrutiny.enable (mkMonitorService {
      name = "scrutiny";
      serviceName = "scrutiny";
      subdomain = cfg.scrutiny.subdomain;
      port = cfg.scrutiny.port;
      enable = cfg.scrutiny.enable;
      smartdEnable = true;
      extraServiceConfig = {};
      extraSystemdConfig = {
        ReadWritePaths = [ "/var/lib/scrutiny" ];
      };
    }).config)

    (lib.mkIf cfg.uptimeKuma.enable (mkMonitorService {
      name = "uptime-kuma";
      serviceName = "uptime-kuma";
      subdomain = cfg.uptimeKuma.subdomain;
      port = cfg.uptimeKuma.port;
      enable = cfg.uptimeKuma.enable;
      extraServiceConfig = {};
    }).config)
  ];
}
