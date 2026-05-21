# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-008"
# title: "Radarr"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [media,radarr,movies]
# description: "Radarr movie manager."
# path: "modules/50-media/57-radarr.nix"
# provides: [my.media.radarr]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/50-media/57-radarr.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.media.radarr = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 7878; };
  };
}
