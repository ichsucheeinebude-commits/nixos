# ---NIXMETA
# ---
# domain: 80
# id: "NIXH-80-GAM-001"
# title: "AMP Game Servers"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [gaming,amp,servers]
# description: "AMP game server management panel."
# path: "modules/80-gaming/80-amp.nix"
# provides: [my.gaming.amp]
# requires: []
# links:
#   adr: docs/adr/ADR-80-amp.md
#   guide: docs/guides/80-amp.md
#   module: modules/80-gaming/80-amp.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.gaming.amp = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 8080; };
    dataDir = lib.mkOption { type = lib.types.str; default = "/var/lib/amp"; };
  };
}
