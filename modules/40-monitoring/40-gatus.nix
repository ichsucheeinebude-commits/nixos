# ---NIXMETA
# ---
# domain: 40
# id: "NIXH-40-MON-001"
# title: "Gatus Health Dashboard"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [monitoring,gatus,health]
# description: "Gatus health monitoring with configurable endpoints."
# path: "modules/40-monitoring/40-gatus.nix"
# provides: [my.monitoring.gatus]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/40-monitoring/40-gatus.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
{
  options.my.monitoring.gatus = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 8081; };
    ntfyUrl = lib.mkOption { type = lib.types.str; default = ""; };
    ntfyTopic = lib.mkOption { type = lib.types.str; default = "gatus-alerts"; };
    endpoints = lib.mkOption { type = lib.types.listOf lib.types.attrs; default = []; };
  };

  config = lib.mkIf config.my.monitoring.gatus.enable {
    services.gatus = {
      enable = true;
      settings = {
        web = { address = "127.0.0.1"; port = config.my.monitoring.gatus.port; };
        storage = { type = "sqlite"; path = "/var/lib/gatus/data.db"; };
        endpoints = config.my.monitoring.gatus.endpoints;
      };
    };
  };
}
