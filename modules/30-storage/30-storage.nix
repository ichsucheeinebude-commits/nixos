# ---NIXMETA
# ---
# domain: 30
# id: "NIXH-30-STO-001"
# title: "Storage Configuration"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [storage,filesystems,tiering]
# description: "File system definitions and ABC tier mount points."
# path: "modules/30-storage/30-storage.nix"
# provides: [my.storage]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/30-storage/30-storage.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.storage = {
    tierA = lib.mkOption { type = lib.types.str; default = "/persist"; description = "Tier A: NVMe state."; };
    tierB = lib.mkOption { type = lib.types.str; default = "/mnt/cache"; description = "Tier B: SSD cache."; };
    tierC = lib.mkOption { type = lib.types.str; default = "/mnt/hdd_pool"; description = "Tier C: HDD archive."; };
    downloads = lib.mkOption { type = lib.types.str; default = "/mnt/cache/downloads"; };
    mediaLibrary = lib.mkOption { type = lib.types.str; default = "/mnt/cache/media"; };
    mediaArchive = lib.mkOption { type = lib.types.str; default = "/mnt/hdd_pool/media"; };
    stateDir = lib.mkOption { type = lib.types.str; default = "/var/lib"; };
    appData = lib.mkOption { type = lib.types.str; default = "/var/lib"; };
    privateData = lib.mkOption { type = lib.types.str; default = "/var/lib/private"; };
    devices = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
    fileSystems = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = {};
    };
  };

  config = {
    fileSystems = lib.mkMerge [ config.my.storage.fileSystems ];
  };
}
