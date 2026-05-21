# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-008"
# title: "Linkding"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [apps,linkding,bookmarks]
# description: "Linkding bookmark manager."
# path: "modules/60-apps/67-linkding.nix"
# provides: [my.apps.linkding]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/60-apps/67-linkding.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.apps.linkding = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 9090; };
  };

  config = lib.mkIf config.my.apps.linkding.enable {
    services.linkding = {
      enable = true;
      host = "127.0.0.1";
      port = config.my.apps.linkding.port;
    };
  };
}
