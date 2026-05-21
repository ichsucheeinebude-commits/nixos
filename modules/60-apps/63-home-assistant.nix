# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-004"
# title: "Home Assistant"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-21
# tags: [apps,home-assistant,automation,iot,smarthome]
# description: "Home Assistant with full option interface from KB automation blueprint."
# path: "modules/60-apps/63-home-assistant.nix"
# provides: [my.apps.home-assistant]
# requires: [10-network, 30-storage]
# links:
#   adr: docs/adr/ADR-60-apps.md
#   guide: docs/guides/60-apps.md
#   module: modules/60-apps/63-home-assistant.nix
# source: services/service-automation-home-assistant.md
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
let
  cfg = config.my.apps.home-assistant;
in
{
  options.my.apps.home-assistant = {
    enable = lib.mkEnableOption "Home Assistant smart home automation";

    # ── Network ──
    listenPort = lib.mkOption {
      type = lib.types.port;
      default = 8123;
      description = "Port for Home Assistant web interface.";
    };

    # ── Database ──
    databaseUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Database URL (e.g., postgresql://user:pass@host/db). SQLite used if null.";
    };

    # ── Packages ──
    extraComponents = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of Home Assistant components to install.";
    };
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra packages for Home Assistant (e.g., ffmpeg, bluetooth tools).";
    };

    # ── Integrations ──
    enableZigbee = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Zigbee integration (requires Zigbee coordinator).";
    };
    zigbeeDevice = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to Zigbee USB device (e.g., /dev/ttyUSB0).";
    };
    enableZwave = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Z-Wave integration.";
    };
    zwaveDevice = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to Z-Wave USB device.";
    };
    enableMatter = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Matter/Thread integration.";
    };

    # ── External Access ──
    externalUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "External URL for Home Assistant (e.g., https://home.m7c5.de).";
    };
    trustedProxies = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "127.0.0.1" "::1" ];
      description = "List of trusted proxy IPs (for reverse proxy setups).";
    };

    # ── Config ──
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/hass";
      description = "Home Assistant configuration directory.";
    };

    # ── OIDC / Auth ──
    oidcEnabled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable OIDC authentication via PocketID.";
    };
    oidcIssuer = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "OIDC issuer URL.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.home-assistant = {
      enable = true;
      openFirewall = false;
      extraComponents = cfg.extraComponents;
      configDir = cfg.configDir;
      extraPackages = cfg.extraPackages;
    };

    # Database configuration via environment
    systemd.services.home-assistant = {
      environment = {
        HA_DATABASE_URL = lib.mkIf (cfg.databaseUrl != null) cfg.databaseUrl;
      };
      serviceConfig = {
        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ReadWritePaths = [ cfg.configDir ];
        # Device access for integrations
        DeviceAllow = lib.mkIf cfg.enableZigbee [
          (lib.mkIf (cfg.zigbeeDevice != null) cfg.zigbeeDevice)
        ];
      };
    };

    # Trusted proxies for reverse proxy
    systemd.services.home-assistant.environment.HA_TRUSTED_PROXIES =
      lib.mkIf (cfg.trustedProxies != [])
        (lib.concatStringsSep "," cfg.trustedProxies);
  };
}
