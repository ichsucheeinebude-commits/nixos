# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-001"
# title: "Media Library"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [media,library,factories]
# description: "Shared media library paths and factory helpers."
# path: "modules/50-media/50-lib-media.nix"
# provides: [my.media.library]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/50-media/50-lib-media.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.media.library = {
    mediaLibrary = lib.mkOption { type = lib.types.str; default = "/mnt/cache/media"; };
    downloads = lib.mkOption { type = lib.types.str; default = "/mnt/cache/downloads"; };
    mediaArchive = lib.mkOption { type = lib.types.str; default = "/mnt/hdd_pool/media"; };
  };
}
