---
domain: 30
id: "NIXH-30-DOM-001"
title: "Domain 30 — Storage Architecture"
type: adr
status: accepted
complexity: 3
reviewed: 2026-05-21
tags:
  - domain
  - 30
  - storage
  - architecture
description: "Architectural decisions for the 30-storage domain."
provides:
  - my.storage.*
requires:
  - my.core.*
links:
  adr: docs/adr/ADR-30-storage.md
  guide: docs/guides/30-storage.md
---

# ADR-30: Domain Storage Architecture

> Three-tier storage (NVMe/ZFS → SSD/EXT4 → HDD/EXT4) with automated tiering, impermanence, and encrypted backup.

---

## Context

Domain 30 governs all storage decisions: the ABC tiering layout (NVMe for hot data, SSD for warm, HDD for cold), automated data migration between tiers, impermanence (stateless root filesystem), backup strategy, and storage policy enforcement. The hardware layout (Q958) dictates physical constraints: NVMe main, SSD in WLAN slot, two HDDs (one in DVD caddy).

---

## Decisions

### 30-30: Storage Configuration
**Decision:** Three-tier ABC layout: Tier A (NVMe/ZFS) for hot data (OS, appdata, databases). Tier B (SSD/EXT4) for warm data (download cache). Tier C (HDD/EXT4) for cold data (media archive). EXT4 for Tier C — no ZFS complexity, any live Linux can read it immediately without `zpool import`.
**Rationale:** ZFS on Tier A provides data integrity for critical data. EXT4 on Tier C enables simple disaster recovery. Physical hardware constraints dictate the tiering.
**Alternatives considered:** All-ZFS (rejected — HDD spin-up overhead, complexity), all-EXT4 (rejected — no data integrity for critical data).

### 30-31: Backup
**Decision:** Local Restic with configurable retention. Master USB stick (LUKS) + S3 backup + Network DNA. Only critical app-state (< 10GB) encrypted via Restic to cloud — not whole disks, just "DNA".
**Rationale:** Restic provides deduplicated, encrypted backups. Encrypting only essential state (not whole disks) minimizes cloud storage costs and transfer time. Master USB enables bare-metal recovery.
**Alternatives considered:** rsync backup (rejected — no deduplication, no encryption), Borg (rejected — Restic has better NixOS support).

### 30-32: Impermanence
**Decision:** Root filesystem on tmpfs (RAM). `/persist` for durable state. Blank snapshot persistence (Misterio77 pattern). Only explicitly listed paths survive boot.
**Rationale:** Prevents state drift. Forces clean declarative configuration. If something breaks, reboot restores known-good state. Secrets and state must be explicitly persisted.
**Alternatives considered:** Persistent root (rejected — state drift, configuration rot).

### 30-33: Storage Policy
**Decision:** Build-time assertions enforce ABC tiering rules. MergerFS rules define which data belongs where. Automatic migration triggers on threshold overrun.
**Rationale:** Policy enforcement prevents misplacement of data (e.g., downloads on Tier A). Build-time assertions catch violations early.
**Alternatives considered:** Manual enforcement (rejected — human error).

### 30-34: Smart Storage Mover
**Decision:** Daily timer moves old data from SSD (Tier B) to HDD (Tier C). ZFS snapshot BEFORE every evacuation. Instant rollback if rsync on Tier B fails.
**Rationale:** Automated tiering optimizes storage utilization. Pre-migration snapshot provides instant rollback safety.
**Alternatives considered:** Manual data migration (rejected — tedious, error-prone), mergerFS auto-tiering (rejected — lacks snapshot safety).

### 30-35: Backup Policy (nixarr pattern)
**Decision:** Structured backup policy with explicit include/exclude rules. Media files ARE backed up. Arr state (`/data/.state/nixarr/*`), SABnzbd state, Jellyfin cache/transcodes, and downloads are NOT backed up (re-downloadable or regenerable). Borgbackup with retention policy (7 daily, 4 weekly, 12 monthly). Encryption enabled.
**Rationale:** Clear backup policy prevents wasting storage on re-downloadable data. Media files are irreplaceable → must be backed up. Borg deduplication minimizes storage cost.
**Alternatives considered:** Full backup (rejected — wasteful for re-downloadable Arr state).

---

## Consequences

### Positive
- Optimal storage utilization via automated tiering
- Fast recovery from any state corruption (reboot resets root)
- Encrypted, deduplicated cloud backup of essential state only
- Build-time policy enforcement prevents storage misconfigurations
- Simple disaster recovery (EXT4 readable without ZFS tooling)

### Negative
- Impermanence requires careful path management — missing a persist path means data loss on reboot
- ZFS snapshot before migration consumes additional disk space temporarily
- Storage Mover runs daily — disk I/O impact (mitigated by scheduling)

---

## Module Inventory

| Module | Purpose |
|--------|---------|
| 30-storage.nix | ABC tiering base config, filesystem layout |
| 31-backup.nix | Restic backup, retention, USB master stick |
| 32-impermanence.nix | tmpfs root, /persist, blank snapshots |
| 33-storage-policy.nix | Build-time assertions, MergerFS rules |
| 34-storage-mover.nix | Automated tiering with ZFS snapshot safety |
| 35-backup-policy.nix | Structured backup policy: include/exclude rules, Borg, retention |

---

## Cross-Domain Dependencies

- Depends on: Domain 00 (core, hardware profile)
- Used by: Domain 50 (media, stores files on tiers), Domain 60 (apps, stores data on Tier A)
