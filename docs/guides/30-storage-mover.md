---
domain: 30
id: "NIXH-30-STM-001"
title: "Storage Mover — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [storage, migration]
description: "Operational guide for storage mover."
path: "guides/30-storage-mover.md"
links:
  adr: docs/adr/ADR-30-storage-mover.md
  guide: docs/guides/30-storage-mover.md
  module: modules/30-storage/34-storage-mover.nix
---

# storage-mover — Storage Mover

**Domain:** 30  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides storage mover.

## Configuration

```nix
my.services.storage_mover.enable = true;
```

## Verification

```bash
systemctl status storage-mover
nixos-option my.services.storage_mover.enable
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

- **Logs:** `journalctl -u storage-mover -f`
- **Reload:** `sudo nixos-rebuild switch`
