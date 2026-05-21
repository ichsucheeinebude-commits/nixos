# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-007"
# title: "Sonarr"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [media,sonarr,tv]
# description: "Sonarr TV series manager."
# path: "modules/50-media/56-sonarr.nix"
# provides: [my.media.sonarr]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/50-media/56-sonarr.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.media.sonarr = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 8989; };
  };
}
