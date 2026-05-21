# ---NIXMETA
# ---
# domain: 80
# id: "NIXH-80-MON-002"
# title: "Netdata (SRE Exhausted)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [netdata,monitoring,metrics,dbengine,real-time]
# description: "Real-time performance monitoring with dbengine retention and strict sandboxing."
# path: "modules/80-monitoring/81-netdata.nix"
# provides: [my.monitoring.netdata]
# requires: [10-network]
# links:
#   module: modules/80-monitoring/81-netdata.nix
#   source: _meta/80-monitoring/service-netdata.nix (NIXH-80-MON-002)
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.monitoring.netdata;
  port = config.my.ports.netdata or 10999;
  domain = config.my.configs.identity.domain or "m7c5.de";
in
{
  options.my.monitoring.netdata = {
    enable = lib.mkEnableOption "Netdata real-time monitoring";
    memoryMode = lib.mkOption { type = lib.types.str; default = "dbengine"; };
    pageCacheSize = lib.mkOption { type = lib.types.str; default = "256"; description = "Page cache size in MB."; };
    dbengineDiskSpace = lib.mkOption { type = lib.types.str; default = "4096"; description = "DBengine disk space in MB."; };
    retentionDays = lib.mkOption { type = lib.types.int; default = 30; };
    history = lib.mkOption { type = lib.types.int; default = 86400; };
    memoryMax = lib.mkOption { type = lib.types.str; default = "1G"; };
    cpuWeight = lib.mkOption { type = lib.types.int; default = 50; };
  };

  config = lib.mkIf cfg.enable {
    services.netdata = {
      enable = true;
      config = {
        global = {
          "memory mode" = cfg.memoryMode;
          "page cache size" = cfg.pageCacheSize;
          "dbengine disk space" = cfg.dbengineDiskSpace;
          "history" = cfg.history;
        };
        web = {
          "allow connections from" = "localhost 127.0.0.1";
          "default port" = toString port;
          "mode" = "static-threaded";
        };
        db = {
          "dbengine tier 1 retention days" = cfg.retentionDays;
        };
        health.enabled = "yes";
      };
    };

    services.caddy.virtualHosts."netdata.${domain}" = {
      extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}";
    };

    systemd.services.netdata.serviceConfig = {
      ProtectSystem = lib.mkForce "full";
      ProtectHome = lib.mkForce true;
      PrivateTmp = lib.mkForce true;
      PrivateDevices = lib.mkForce true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = [ "CAP_DAC_READ_SEARCH" "CAP_SYS_PTRACE" "CAP_NET_RAW" ];
      AmbientCapabilities = [ "CAP_DAC_READ_SEARCH" "CAP_SYS_PTRACE" "CAP_NET_RAW" ];
      MemoryMax = cfg.memoryMax;
      CPUWeight = cfg.cpuWeight;
      OOMScoreAdjust = 1000;
    };
  };
}
