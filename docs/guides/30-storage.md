---
domain: 30
id: "NIXH-30-STO-001"
title: "Storage Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
source: "architectural-legacy-v6.7"
tags: [storage,filesystems]
description: "Configure storage tiers."
path: "docs/guides/GUIDE-30-storage.md"
links:
  module: "modules/30-storage/30-storage.nix"
---

# Guide: Storage Guide

Define mounts in host config.


---

## KB Nuggets

### MergerFS Design
`category.create=mfs` (Most Free Space) füllt EXT4-Platten gleichmäßig. `cache.files=auto-full` für 4K-Streaming Performance.
### Hysterese (90% → 80%)
Vermeidet Trashing (ständiges Hin- und Her-Schieben). Mover sammelt Arbeit bis substanzieller Batch (10% der Platte).
