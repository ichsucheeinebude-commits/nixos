---
domain: 30
id: "NIXH-30-STP-001"
title: "Storage Policy — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [policy, tiering]
description: "Operational guide for storage policy."
path: "guides/30-storage-policy.md"
links:
  adr: docs/adr/ADR-30-storage-policy.md
  guide: docs/guides/30-storage-policy.md
  module: modules/30-storage/33-storage-policy.nix
---

# storage-policy — Storage Policy

**Domain:** 30  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides storage policy.

## Configuration

```nix
my.services.storage_policy.enable = true;
```

## Verification

```bash
systemctl status storage-policy
nixos-option my.services.storage_policy.enable
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

- **Logs:** `journalctl -u storage-policy -f`
- **Reload:** `sudo nixos-rebuild switch`
