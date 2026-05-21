---
domain: 30
id: "NIXH-30-STO-002"
title: "Backup"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [storage,backup,restic]
description: "Restic backup strategy."
path: "docs/adr/ADR-31-backup.md"
links:
  module: "modules/30-storage/31-backup.nix"
---

# ADR: Backup

## Decision
Local Restic with configurable retention.


---

## KB Nuggets

### Disaster Recovery v6.1
Master-USB-Stick (LUKS) + S3-Backup + Network DNA = vollautomatische Recovery auf neuer Hardware.
### Encrypted State-Streaming
Nur kritischer App-State (< 10GB) via Restic verschlüsselt in die Cloud. Nicht ganze Platten — nur DNA.
