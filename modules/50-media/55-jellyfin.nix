# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-006"
# title: "Jellyfin"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [media,jellyfin,streaming]
# description: "Jellyfin media server with hardware acceleration."
# path: "modules/50-media/55-jellyfin.nix"
# provides: [my.media.jellyfin]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/50-media/55-jellyfin.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.media.jellyfin = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    gpuAcceleration = lib.mkOption { type = lib.types.bool; default = false; };
    dataDir = lib.mkOption { type = lib.types.str; default = "/var/lib/jellyfin"; };
  };

  config = lib.mkIf config.my.media.jellyfin.enable {
    services.jellyfin = {
      enable = true;
      dataDir = config.my.media.jellyfin.dataDir;
    };
  };
}
