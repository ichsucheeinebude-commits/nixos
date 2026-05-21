# ---NIXMETA---
# domain: 30-storage
# id: NIXH-30-STO-001
# status: draft
# provides:
#   - my.storage.enable
# requires:
#   - 00-core
#   - 10-network
# adr: ADR-30-storage.md
# guide: 30-storage.md
# complexity: 3
# reviewed: YYYY-MM-DD
# ---ENDNIXMETA---
#
# PURPOSE: ABC-tiering, mergerfs, ZFS, backup.
# Key decisions: docs/adr/ADR-30-storage.md

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
