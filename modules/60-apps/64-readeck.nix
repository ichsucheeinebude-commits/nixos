# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-005"
# title: "Readeck"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [apps,readeck,reader]
# description: "Readeck read-it-later service."
# path: "modules/60-apps/64-readeck.nix"
# provides: [my.apps.readeck]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/60-apps/64-readeck.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.apps.readeck = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 8000; };
  };

  config = lib.mkIf config.my.apps.readeck.enable {
    services.readeck = {
      enable = true;
      settings = {
        server.host = "127.0.0.1";
        server.port = config.my.apps.readeck.port;
      };
    };
  };
}
