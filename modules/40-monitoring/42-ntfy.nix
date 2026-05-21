# ---NIXMETA
# ---
# domain: 40
# id: "NIXH-40-MON-003"
# title: "ntfy-sh"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [monitoring,ntfy,alerting]
# description: "Local ntfy-sh notification server."
# path: "modules/40-monitoring/42-ntfy.nix"
# provides: [my.monitoring.ntfy]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/40-monitoring/42-ntfy.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.monitoring.ntfy = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 2586; };
  };

  config = lib.mkIf config.my.monitoring.ntfy.enable {
    services.ntfy-sh = {
      enable = true;
      settings = {
        listen-http = "127.0.0.1:${toString config.my.monitoring.ntfy.port}";
        behind-proxy = true;
      };
    };
  };
}
