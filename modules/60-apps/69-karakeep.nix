# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-010"
# title: "Karakeep"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [apps,karakeep,bookmarks]
# description: "Karakeep bookmark management."
# path: "modules/60-apps/69-karakeep.nix"
# provides: [my.apps.karakeep]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/60-apps/69-karakeep.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.apps.karakeep = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 3012; };
    disableSignups = lib.mkOption { type = lib.types.bool; default = true; };
  };

  config = lib.mkIf config.my.apps.karakeep.enable {
    services.karakeep = {
      enable = true;
      extraEnvironment = {
        PORT = toString config.my.apps.karakeep.port;
        DISABLE_SIGNUPS = if config.my.apps.karakeep.disableSignups then "true" else "false";
      };
    };
  };
}
