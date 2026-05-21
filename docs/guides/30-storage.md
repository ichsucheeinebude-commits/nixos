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

### ---

title: 🏗️ ABC-Storage-Tiering (The Hybrid ZFS + MergerFS Standard)
category: architecture/storage
status: [ACTIVE-SSoT]
capabilities: [zfs-integrity, mergerfs-flexibility, hybrid-pooling, snapraid-parity]
sources: [https://perfectmediaserver.com/02-tech-stack/nixos/]
---

# 🏗️ ABC-Storage-Tiering: Das Hybride Storage-Manifest

Dieses System kombiniert das Beste aus zwei Welten: Die absolute Datensicherheit von ZFS und die einfache Skalierbarkeit von MergerFS.

### 🔴 Tier A: Critical Data (ZFS Native)

- **Inhalt:** Unersetzbare Daten (Fotos, Dokumente, Sops-Secrets, DBs).
- **Technik:** ZFS Mirror oder RaidZ.
- **Vorteil:** Schutz vor Bit-Rot, atomare Snapshots, einfache Remote-Replikation via Syncoid.

### 🔵 Tier C: Bulk Media (MergerFS + SnapRAID)

- **Inhalt:** Ersetzbare Medien (Linux ISOs, Filme, Serien).
- **Technik:** MergerFS pooling von Mismatch-Drives + SnapRAID Parität.
- **Vorteil:** Kosteneffizient, jede Platte einzeln lesbar, kein Rebuild-Stress.

### 🧩 Die Hybride Synthese (The Master Mount)

Wir mergen die ZFS-Datasets und die JBOD-Platten zu einem einzigen logischen Pfad (\`/mnt/storage\`).
