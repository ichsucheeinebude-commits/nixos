---
domain: 30
id: "NIXH-30-BKP-001"
title: "Restic Backup — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [backup, restic]
description: "Operational guide for restic backup."
path: "guides/30-backup.md"
links:
  adr: docs/adr/ADR-30-backup.md
  guide: docs/guides/30-backup.md
  module: modules/30-storage/31-backup.nix
---

# backup — Restic Backup

**Domain:** 30  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides restic backup.

## Configuration

```nix
my.services.backup.enable = true;
```

## Verification

```bash
systemctl status backup
nixos-option my.services.backup.enable
```

## Known Failure Modes

| Symptom | Cause | Fix |
|---|---|---|
| Service fails to start | Port conflict | Change port |
| Exit code 127 | Binary missing | Run `nix flake update` |

## Dependencies

- **Requires:** See NIXMETA header
- **Required by:** Higher-domain modules

## Maintenance

- **Logs:** `journalctl -u backup -f`
- **Reload:** `sudo nixos-rebuild switch`
