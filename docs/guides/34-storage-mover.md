---
domain: 30
id: "NIXH-30-STM-001"
title: "Storage Mover — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [storage, migration]
description: "Storage Mover module."
path: "root/guides/34-storage-mover.md"
links:
  adr: ADR-34-storage-mover.md
  guide: 34-storage-mover.md
  module: modules/30-storage/34-storage-mover.nix
---

# "Storage Mover"

**Domain:** 30-storage
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-30-STM-001"

---

## Overview

This module provides "storage mover" functionality for the NixOS system.
"Storage Mover module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."storage-mover".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "storage-mover"

# Check config was applied
nixos-option my.services."storage-mover".enable

# Check logs
journalctl -u "storage-mover" -f --no-pager
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

- **Log location:** `journalctl -u "storage-mover" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
