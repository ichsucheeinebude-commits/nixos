---
domain: 90
id: "NIXH-92-DEF-001"
title: "Deferred Storage Operations — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [storage, deferred, operations, hdd]
description: "Deferred deletion operations for storage that respect HDD sleep cycles."
path: "root/guides/92-deferred-ops.md"
links:
  adr: ADR-92-deferred-ops.md
  guide: 92-deferred-ops.md
  module: modules/90-policy/92-deferred-ops.nix
---

# Deferred Storage Operations

**Domain:** 90-policy
**Status:** Draft
**Complexity:** 1/5
**ID:** NIXH-92-DEF-001

---

## Overview

This module provides deferred storage operations functionality for the NixOS system.
Deferred deletion operations for storage that respect HDD sleep cycles.
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
my.services.deferred-storage-operations.enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.

## Verification

```bash
systemctl status deferred-storage-operations
nixos-option my.services.deferred-storage-operations.enable
journalctl -u deferred-storage-operations -f --no-pager
```

## Known Failure Modes

| Symptom | Cause | Fix |
|---|---|---|
| Timer not running | Systemd timer not enabled | Check systemctl status of deferred-ops timer |
| HDD woken unnecessarily | find accessing disk | Adjust maxAgeDays threshold |
| Queue not processed | HDD never wakes up | Check hdparm spindown settings |

## Dependencies

- **Requires:** `00-principles.nix`, `01-configs-registry.nix`
- **Required by:** Higher-domain modules that consume this service

## Maintenance

- **Log location:** `journalctl -u deferred-storage-operations -f`
- **Config reload:** `sudo nixos-rebuild switch`
