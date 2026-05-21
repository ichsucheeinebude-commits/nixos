# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-002"
# title: "Arr Stack"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [media,arr,radarr,sonarr,prowlarr]
# description: "*Arr media management stack."
# path: "modules/50-media/51-arr-stack.nix"
# provides: [my.media.arr]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/50-media/51-arr-stack.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.media.arr = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    radarrPort = lib.mkOption { type = lib.types.port; default = 7878; };
    sonarrPort = lib.mkOption { type = lib.types.port; default = 8989; };
    prowlarrPort = lib.mkOption { type = lib.types.port; default = 9696; };
  };

  config = lib.mkIf config.my.media.arr.enable {
    services.radarr.enable = true;
    services.sonarr.enable = true;
    services.prowlarr.enable = true;
  };
}
