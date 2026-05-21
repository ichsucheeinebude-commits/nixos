# ---NIXMETA
# ---
# domain: 80
# id: "NIXH-80-MON-003"
# title: "Scrutiny (SRE Hardened)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [scrutiny,smart,monitoring,hardware,health]
# description: "Drive S.M.A.R.T monitoring with InfluxDB trends and strict sandboxing."
# path: "modules/80-monitoring/82-scrutiny.nix"
# provides: [my.monitoring.scrutiny]
# requires: [10-network]
# links:
#   module: modules/80-monitoring/82-scrutiny.nix
# source: _meta/80-monitoring/service-scrutiny.nix (NIXH-80-MON-003)
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.monitoring.scrutiny;
  port = config.my.ports.scrutiny or 20007;
  domain = config.my.configs.identity.domain or "m7c5.de";
in
{
  options.my.monitoring.scrutiny = {
    enable = lib.mkEnableOption "Scrutiny S.M.A.R.T monitoring";
    logLevel = lib.mkOption { type = lib.types.enum [ "DEBUG" "INFO" "WARNING" "ERROR" ]; default = "INFO"; };
  };

  config = lib.mkIf cfg.enable {
    services.scrutiny = {
      enable = true;
      settings = {
        web.listen.port = port;
        web.listen.host = "127.0.0.1";
        log.level = cfg.logLevel;
      };
      influxdb.enable = true;
      collector = {
        enable = true;
        schedule = "daily";
      };
    };

    services.caddy.virtualHosts."scrutiny.${domain}" = {
      extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}";
    };

    systemd.services.scrutiny.serviceConfig = {
      DynamicUser = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      OOMScoreAdjust = 800;
    };

    services.smartd.enable = true;
  };
}
