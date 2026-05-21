# ---NIXMETA
# ---
# domain: 40
# id: "NIXH-40-MON-005"
# title: "Vector Log Aggregator"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [monitoring,vector,logging]
# description: "Vector centralized log pipeline."
# path: "modules/40-monitoring/44-vector.nix"
# provides: [my.monitoring.vector]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/40-monitoring/44-vector.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.monitoring.vector = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    logDir = lib.mkOption { type = lib.types.str; default = "/var/log/vector"; };
  };

  config = lib.mkIf config.my.monitoring.vector.enable {
    services.vector = {
      enable = true;
      journaldAccess = true;
      settings = {
        sources = { journal = { type = "journald"; }; };
        sinks = {
          file_output = {
            type = "file";
            path = "${config.my.monitoring.vector.logDir}/all-logs-%Y-%m-%d.json";
            inputs = [ "journal" ];
            encoding = { codec = "json"; };
          };
        };
      };
    };
    systemd.tmpfiles.rules = [ "d ${config.my.monitoring.vector.logDir} 0750 vector vector -" ];
  };
}
