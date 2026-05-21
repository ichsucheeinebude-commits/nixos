# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-003"
# title: "Download Stack"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [media,download,sabnzbd]
# description: "SABnzbd download manager."
# path: "modules/50-media/52-download.nix"
# provides: [my.media.downloads]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/50-media/52-download.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.media.downloads = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
  };

  config = lib.mkIf config.my.media.downloads.enable {
    services.sabnzbd.enable = true;
  };
}
