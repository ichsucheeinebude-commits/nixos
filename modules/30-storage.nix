# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-30-STO-001",
#   "title": "Storage Configuration",
#   "layer": 30,
#   "category": "storage",
#   "lastReviewed": "YYYY-MM-DD",
#   "reviewedBy": "moritz",
#   "status": "draft",
#   "complexity": 3,
#   "description": "ABC-tiering, mergerfs, ZFS, backup",
#   "tags": ["storage", "zfs", "mergerfs", "tiering", "backup"]
# }
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

# ── Storage Module ────────────────────────────────────────────────────
# ABC-Tiering, mergerfs, backup

let
  cfg = config.my.storage;
in {

  options.my.storage = {
    enable = lib.mkEnableOption "storage module";
  };

  config = lib.mkIf cfg.enable {
    # TODO: ABC-tiering implementation
    # Tier A (Hot): NVMe → /persist
    # Tier B (Warm): SSD → /mnt/data
    # Tier C (Cold): HDD pool → /mnt/media
  };
}
