---
domain: 30
id: "NIXH-30-BKP-001"
title: "Restic Backup — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [backup, restic]
description: "Restic Backup module."
path: "root/guides/31-backup.md"
links:
  adr: ADR-31-backup.md
  guide: 31-backup.md
  module: modules/30-storage/31-backup.nix
---

# "Restic Backup"

**Domain:** 30-storage
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-30-BKP-001"

---

## Overview

This module provides "restic backup" functionality for the NixOS system.
"Restic Backup module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."restic-backup".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "restic-backup"

# Check config was applied
nixos-option my.services."restic-backup".enable

# Check logs
journalctl -u "restic-backup" -f --no-pager
```

## Known Failure Modes

| Symptom | Cause | Fix |
|---|---|---|
| Mount fails | Disk not available | Check `lsblk` and verify device names |
| Poor performance | Cache settings suboptimal | Tune cache.files and category.create options |
| HDDs won't spin down | Services accessing disk | Use `lsof` to find accessing service |

## Dependencies

- **Requires:** `00-principles.nix`, `01-configs-registry.nix` (and others per NIXMETA `requires`)
- **Required by:** Higher-domain modules that consume this service

## Maintenance

- **Log location:** `journalctl -u "restic-backup" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
