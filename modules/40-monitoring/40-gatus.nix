# ---NIXMETA
# ---
# domain: 40
# id: "NIXH-40-MON-001"
# title: "Gatus Monitoring"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-21
# tags: [monitoring,gatus,health-checks,alerting,status-page]
# description: "Gatus health monitoring with endpoints from KB and Matrix alerting."
# path: "modules/40-monitoring/40-gatus.nix"
# provides: [my.monitoring.gatus]
# requires: [10-network]
# links:
#   adr: docs/adr/ADR-40-gatus.md
#   guide: docs/guides/40-gatus.md
#   module: modules/40-monitoring/40-gatus.nix
# source: guides/MASTER-CONFIG-GATUS.md
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
let
  cfg = config.my.monitoring.gatus;
in
{
  options.my.monitoring.gatus = {
    enable = lib.mkEnableOption "Gatus health monitoring and status page";

    # ── Network ──
    listenPort = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port for Gatus web interface.";
    };

    # ── Endpoints ──
    endpoints = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption { type = lib.types.str; description = "Endpoint name."; };
          url = lib.mkOption { type = lib.types.str; description = "URL to monitor."; };
          method = lib.mkOption {
            type = lib.types.enum [ "GET" "POST" "PUT" "DELETE" "HEAD" ];
            default = "GET";
            description = "HTTP method.";
          };
          interval = lib.mkOption {
            type = lib.types.str;
            default = "1m";
            description = "Check interval.";
          };
          conditions = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "[STATUS] == 200" "[RESPONSE_TIME] < 500" ];
            description = "Conditions for health check.";
          };
          alerts = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable alerts for this endpoint.";
          };
        };
      });
      default = [
        { name = "caddy"; url = "https://localhost:443"; }
        { name = "pocket-id"; url = "http://localhost:8080"; }
        { name = "fail2ban"; url = "http://localhost:8081"; }
      ];
      description = "List of endpoints to monitor.";
    };

    # ── Alerting ──
    matrixAlerting = {
      enabled = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Matrix alerting via matrix-hook.";
      };
      webhookUrl = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Matrix webhook URL for alerts.";
      };
      roomId = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Matrix room ID for alerts.";
      };
    };
    ntfyAlerting = {
      enabled = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable ntfy.sh alerting.";
      };
      topic = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "ntfy.sh topic for alerts.";
      };
      serverUrl = lib.mkOption {
        type = lib.types.str;
        default = "https://ntfy.sh";
        description = "ntfy.sh server URL.";
      };
    };

    # ── Storage ──
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/gatus";
      description = "Data directory for Gatus SQLite database.";
    };

    # ── Retention ──
    resultRetention = lib.mkOption {
      type = lib.types.str;
      default = "168h";
      description = "How long to keep health check results (1 week).";
    };
    eventRetention = lib.mkOption {
      type = lib.types.str;
      default = "720h";
      description = "How long to keep events (30 days).";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gatus = {
      enable = true;
      settings = {
        storage = {
          type = "sqlite";
          path = "${cfg.dataDir}/gatus.db";
        };
        web = {
          port = cfg.listenPort;
        };
        metrics = true;
        endpoints = map (ep: {
          name = ep.name;
          url = ep.url;
          method = ep.method;
          interval = ep.interval;
          conditions = ep.conditions;
          alerts = lib.mkIf ep.alerts [{
            type = "default";
            send-on-resolved = true;
          }];
        }) cfg.endpoints;
        alerting = {
          matrix = lib.mkIf cfg.matrixAlerting.enabled {
            webhook-url = cfg.matrixAlerting.webhookUrl;
          };
          ntfy = lib.mkIf cfg.ntfyAlerting.enabled {
            topic = cfg.ntfyAlerting.topic;
            url = cfg.ntfyAlerting.serverUrl;
          };
        };
        metrics = true;
        endpoints = map (ep: {
          name = ep.name;
          url = ep.url;
          method = ep.method;
          interval = ep.interval;
          conditions = ep.conditions;
        }) cfg.endpoints;
        storage = {
          type = "sqlite";
          path = "${cfg.dataDir}/gatus.db";
          cleanup = {
            older-than = cfg.resultRetention;
          };
        };
        web = {
          port = cfg.listenPort;
        };
      };
    };

    # ── Systemd Hardening ──
    systemd.services.gatus.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [ cfg.dataDir ];
    };
  };
}
