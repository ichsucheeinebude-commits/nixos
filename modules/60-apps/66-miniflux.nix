# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-007"
# title: "Miniflux RSS"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [apps,miniflux,rss]
# description: "Miniflux RSS reader."
# path: "modules/60-apps/66-miniflux.nix"
# provides: [my.apps.miniflux]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/60-apps/66-miniflux.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.apps.miniflux = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 8085; };
  };

  config = lib.mkIf config.my.apps.miniflux.enable {
    services.miniflux = {
      enable = true;
      config = {
        LISTEN_ADDR = "127.0.0.1:${toString config.my.apps.miniflux.port}";
        RUN_MIGRATIONS = 1;
      };
    };
  };
}
