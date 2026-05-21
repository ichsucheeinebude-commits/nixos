# ---NIXMETA
---
domain: 30
id: "NIXH-30-STO-001"
title: "Storage Strategy"
type: module
status: draft
complexity: 3
reviewed: YYYY-MM-DD
tags:
  - storage
  - zfs
  - mergerfs
  - tiering
  - backup
description: "ABC-tiering, mergerfs, ZFS, backup"
provides:
  - my.storage.enable
requires:
  - 00-core
  - 10-network
links:
  adr: ADR-30-storage.md
  guide: 30-storage.md
  module: modules/30-storage.nix
---
# ---ENDNIXMETA

---
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
