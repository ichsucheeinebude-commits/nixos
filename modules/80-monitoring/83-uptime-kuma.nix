# ---NIXMETA
# ---
# domain: 80
# id: "NIXH-80-MON-004"
# title: "Uptime Kuma (SRE Exhausted)"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [uptime-kuma,monitoring,uptime,dashboard]
# description: "Self-hosted uptime monitoring with strict sandboxing and resource limits."
# path: "modules/80-monitoring/83-uptime-kuma.nix"
# provides: [my.monitoring.uptimeKuma]
# requires: [10-network]
# links:
#   module: modules/80-monitoring/83-uptime-kuma.nix
# source: _meta/80-monitoring/uptime-kuma.nix (NIXH-80-MON-004)
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.monitoring.uptimeKuma;
  port = config.my.ports.uptimeKuma or 10001;
  domain = config.my.configs.identity.domain or "m7c5.de";
in
{
  options.my.monitoring.uptimeKuma = {
    enable = lib.mkEnableOption "Uptime Kuma monitoring";
  };

  config = lib.mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;
      settings.PORT = toString port;
    };

    services.caddy.virtualHosts."status.${domain}" = {
      extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}";
    };

    systemd.services.uptime-kuma.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = [ "CAP_NET_RAW" ];
      AmbientCapabilities = [ "CAP_NET_RAW" ];
      MemoryMax = "512M";
      CPUWeight = 30;
      OOMScoreAdjust = 500;
    };
  };
}
