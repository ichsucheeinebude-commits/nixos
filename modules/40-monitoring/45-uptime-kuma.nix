# ---NIXMETA
# ---
# domain: 40
# id: "NIXH-40-MON-006"
# title: "Uptime Kuma"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [monitoring,uptime-kuma,uptime]
# description: "Uptime Kuma monitoring dashboard."
# path: "modules/40-monitoring/45-uptime-kuma.nix"
# provides: [my.monitoring.uptimeKuma]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/40-monitoring/45-uptime-kuma.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.monitoring.uptimeKuma = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 3001; };
  };

  config = lib.mkIf config.my.monitoring.uptimeKuma.enable {
    services.uptime-kuma = {
      enable = true;
      settings.PORT = toString config.my.monitoring.uptimeKuma.port;
    };
  };
}
