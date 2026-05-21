# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-008"
# title: "Tailscale Zero-Trust Network"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-21
# tags: [network,tailscale,zerotrust,vpn,tailnet]
# description: "Tailscale Zero-Trust network with full option interface from MASTER-CONFIG-TAILSCALE."
# path: "modules/10-network/19-zigbee-stack.nix"
# provides: [my.network.tailscale]
# requires: [10-network]
# links:
#   adr: docs/adr/ADR-19-zigbee-stack.md
#   guide: docs/guides/19-zigbee-stack.md
#   module: modules/10-network/19-zigbee-stack.nix
# source: guides/MASTER-CONFIG-TAILSCALE.md
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
let
  cfg = config.my.network.tailscale;
in
{
  options.my.network.tailscale = {
    enable = lib.mkEnableOption "Tailscale Zero-Trust VPN";

    # ── Auth ──
    authKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to file containing Tailscale auth key (via SOPS).";
    };

    # ── Network ──
    acceptDns = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Accept DNS configuration from the tailnet.";
    };
    acceptRoutes = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Accept subnet routes from other nodes.";
    };
    advertiseRoutes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Subnet routes to advertise (e.g., ['192.168.1.0/24']).";
    };
    advertiseExitNode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Advertise this node as an exit node.";
    };

    # ── Security ──
    allowIngress = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Allow Tailscale ingress from other tailnet nodes.";
    };
    allowAdminConsoleRemoteUpdate = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Allow remote admin console updates.";
    };

    # ── Firewall ──
    firewallMode = lib.mkOption {
      type = lib.types.enum [ "auto" "on" "off" ];
      default = "auto";
      description = "Tailscale firewall mode.";
    };

    # ── Debug ──
    debugEnvFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to debug environment variables file.";
    };
    logLevel = lib.mkOption {
      type = lib.types.enum [ "verbose" "info" "warn" "error" ];
      default = "info";
      description = "Tailscale daemon log level.";
    };

    # ── Config ──
    configFilePath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Custom path for Tailscale state file.";
    };
    port = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
      description = "Custom UDP port for WireGuard traffic (default 41641).";
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      port = cfg.port;
      useRoutingFeatures = if cfg.advertiseExitNode then "server" else "client";
      extraUpFlags = [
        "--accept-dns=${if cfg.acceptDns then "true" else "false"}"
        "--accept-routes=${if cfg.acceptRoutes then "true" else "false"}"
      ] ++ lib.optionals cfg.advertiseExitNode [ "--advertise-exit-node" ]
        ++ lib.optionals (cfg.advertiseRoutes != []) [ "--advertise-routes=${lib.concatStringsSep "," cfg.advertiseRoutes}" ];
    };

    # Environment variables for tailscaled
    systemd.services.tailscaled.environment = {
      TS_AUTHKEY_FILE = lib.mkIf (cfg.authKeyFile != null) cfg.authKeyFile;
      TS_ACCEPT_DNS = if cfg.acceptDns then "1" else "0";
      TS_ALLOW_SELF_INGRESS = if cfg.allowIngress then "1" else "0";
      TS_ALLOW_ADMIN_CONSOLE_REMOTE_UPDATE = if cfg.allowAdminConsoleRemoteUpdate then "1" else "0";
      TS_DEBUG_ENV_FILE = lib.mkIf (cfg.debugEnvFile != null) cfg.debugEnvFile;
      TS_DEBUG_LOG_RATE = cfg.logLevel;
      TS_FIREWALL_MODE = cfg.firewallMode;
      TS_CONFIGFILE_PATH = lib.mkIf (cfg.configFilePath != null) cfg.configFilePath;
    };

    # ── Systemd Hardening ──
    systemd.services.tailscaled.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      CapabilityBoundingSet = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];
    };

    # ── NFTables: Allow tailscale traffic ──
    networking.firewall = {
      allowedUDPPorts = lib.mkIf (cfg.port != null) [ cfg.port ];
      trustedInterfaces = [ "tailscale0" ];
    };
  };
}
