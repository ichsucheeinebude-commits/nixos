---
domain: 30
id: "NIXH-30-STO-005"
title: "Smart Storage Mover"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [storage,mover]
description: "Automated tiering mover."
path: "docs/adr/ADR-34-storage-mover.md"
links:
  module: "modules/30-storage/34-storage-mover.nix"
---

# ADR: Smart Storage Mover

## Decision
Daily timer moves old data from SSD to HDD.


---

## KB Nuggets

=== Storage Mover mit Snapshot-Safety
`zfs snapshot` VOR jeder Evakuierung. Sofortiges Rollback falls rsync auf Tier B fehlschlägt.
