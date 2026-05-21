# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-009"
# title: "Prowlarr"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [media,prowlarr,indexer]
# description: "Prowlarr indexer manager."
# path: "modules/50-media/58-prowlarr.nix"
# provides: [my.media.prowlarr]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/50-media/58-prowlarr.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.media.prowlarr = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 9696; };
  };
}
