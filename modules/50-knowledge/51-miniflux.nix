# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-KNW-002"
# title: "Miniflux (SRE Exhausted)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [miniflux,rss,socket-activation,wake-on-access,sandboxing]
# description: "Minimalist RSS reader with Wake-on-Access (socket activation) and strict sandboxing."
# path: "modules/50-knowledge/51-miniflux.nix"
# provides: [my.knowledge.miniflux]
# requires: [10-network, 20-security]
# links:
#   module: modules/50-knowledge/51-miniflux.nix
# source: _meta/50-knowledge/service-app-miniflux.nix (NIXH-50-KNW-002)
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.knowledge.miniflux;
  port = config.my.ports.miniflux or 20008;
  domain = config.my.configs.identity.domain or "m7c5.de";
in
{
  options.my.knowledge.miniflux = {
    enable = lib.mkEnableOption "Miniflux RSS reader";
    adminUsername = lib.mkOption { type = lib.types.str; default = "admin"; };
    adminCredentialsFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/secrets/miniflux_admin_password";
      description = "Path to admin credentials file.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.miniflux = {
      enable = true;
      config = {
        LISTEN_ADDR = "fd://3";
        WATCHDOG = 1;
        RUN_MIGRATIONS = 1;
        ADMIN_USERNAME = cfg.adminUsername;
      };
      createDatabaseLocally = true;
      adminCredentialsFile = cfg.adminCredentialsFile;
    };

    # Wake-on-Access via socket activation
    systemd.sockets.miniflux = {
      description = "Miniflux Socket";
      wantedBy = [ "sockets.target" ];
      listenStreams = [ (toString port) ];
    };

    systemd.services.miniflux = {
      wantedBy = lib.mkForce [];
      requires = [ "miniflux.socket" ];
      after = [ "miniflux.socket" ];
      serviceConfig = {
        DynamicUser = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        SystemCallFilter = [ "@system-service" "~@privileged" ];
        OOMScoreAdjust = 500;
      };
    };
  };
}
