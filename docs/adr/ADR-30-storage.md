---
domain: 30
id: "NIXH-30-STO-001"
title: "Storage Configuration"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [storage,filesystems]
description: "ABC tiering storage layout."
path: "docs/adr/ADR-30-storage.md"
links:
  module: "modules/30-storage/30-storage.nix"
---

# ADR: Storage Configuration

## Decision
Three-tier: NVMe, SSD, HDD.


---

## KB Nuggets

### ABC Storage Masterplan v5.3
Tier A (NVMe/ZFS): Hot Data. Tier B (SSD/EXT4): Warm. Tier C (HDD/EXT4): Cold/Friedhof.
### EXT4 für den Friedhof
Medien-Archive brauchen keine ZFS-Komplexität. EXT4 = Safe-Recovery: Jedes Live-Linux kann Daten sofort lesen ohne `zpool import`.
