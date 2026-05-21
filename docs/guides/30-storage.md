---
domain: 30
id: "NIXH-30-DOM-001"
title: "Domain 30 — Storage Guide"
type: guide
status: draft
complexity: 2
reviewed: 2026-05-21
tags:
  - domain
  - 30
  - storage
  - operations
description: "Operational guide for the 30-storage domain."
links:
  adr: ADR-30-storage.md
  guide: 30-storage.md
---

# 30-storage: Domain Storage Guide

> Operational procedures for ABC tiering, backup, impermanence, storage policy, and automated data migration.

---

## Prerequisites

- Domain 00 (core) deployed
- Hardware with NVMe, SSD, and HDD available
- ZFS installed (for Tier A)
- Restic installed (for backup)

---

## Module Operations (ODR-sorted)

### 30-30: Storage Configuration
**Enable:** Define Tier A (NVMe/ZFS), Tier B (SSD/EXT4), Tier C (HDD/EXT4) mount points in host config.
**Verify:** `df -h` shows all tiers mounted. `zpool status` shows ZFS pool health. `mount | grep tier` shows mount points.
**Troubleshooting:** ZFS pool not importing — check `zpool import`. EXT4 not mounting — check fstab entries.

### 30-31: Backup
**Enable:** `my.storage.backup.enable = true;` Configure Restic repository and retention policy. Master USB stick must be LUKS-encrypted.
**Verify:** `restic -r <repo> snapshots` shows backup history. `systemctl list-timers | grep restic` shows schedule.
**Troubleshooting:** Backup fails — check repository access. USB stick not detected — verify LUKS unlock.

### 30-32: Impermanence
**Enable:** `my.storage.impermanence.enable = true;` Define persist paths in `my.storage.impermanence.paths`.
**Verify:** After reboot, only /persist paths survive. `mount | grep tmpfs` shows root on tmpfs.
**Troubleshooting:** Data lost after reboot — add path to persist list. Check `/persist` mount exists.

### 30-33: Storage Policy
**Enable:** Enabled by default. Assertions fire at build time on policy violations.
**Verify:** `nixos-rebuild switch` fails if policy violated. Error message shows specific violation.
**Troubleshooting:** Assertion failure — review error message. Use `lib.mkForce` only if legitimate override needed.

### 30-34: Smart Storage Mover
**Enable:** `my.storage.mover.enable = true;` Configure thresholds and schedule.
**Verify:** `systemctl list-timers | grep mover` shows schedule. Check logs: `journalctl -u storage-mover`. ZFS snapshots: `zfs list -t snapshot`.
**Troubleshooting:** Move failed — check ZFS snapshot for rollback. `zfs rollback <snapshot>` restores previous state.

---

## Cross-Domain Interactions

- Depends on: Domain 00 (core, hardware profile)
- Used by: Domain 50 (media, stores on tiers), Domain 60 (apps, stores on Tier A)
