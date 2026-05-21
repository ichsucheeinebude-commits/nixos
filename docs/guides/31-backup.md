---
domain: 30
id: "NIXH-30-STO-002"
title: "Backup Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [storage,backup]
description: "Configure backups."
path: "docs/guides/GUIDE-31-backup.md"
links:
  module: "modules/30-storage/31-backup.nix"
---

# Guide: Backup Guide

Set repository and paths.


---

## KB Nuggets

### Restic Daily + Rclone
Tägliche Snapshots. Rclone-Sync zu S3/Wasabi/Backblaze. Retention: 7 daily, 4 weekly, 12 monthly.
### Pro Backup Strategies
Ransomware-Schutz: Unveränderliche Snapshots. Cloud-Mounts für schnellen Restore. Verify nach jedem Backup.
