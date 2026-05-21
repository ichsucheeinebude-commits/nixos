---
domain: 00
id: "NIXH-00-COR-007"
title: "ZRAM Swap — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,zram,swap,memory]
description: "Compressed RAM swap via zram."
path: "root/guides/06-zram-swap.md"
links:
  adr: ADR-06-zram-swap.md
  guide: 06-zram-swap.md
  module: modules/00-core/06-zram-swap.nix
---

# "ZRAM Swap"

**Domain:** 00-core
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-00-COR-007"

---

## Overview

This module provides "zram swap" functionality for the NixOS system.
"Compressed RAM swap via zram."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."zram-swap".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "zram-swap"

# Check config was applied
nixos-option my.services."zram-swap".enable

# Check logs
journalctl -u "zram-swap" -f --no-pager
```

## Known Failure Modes

| Symptom | Cause | Fix |
|---|---|---|
| Eval error | Conflicting option definitions | Check for duplicate definitions with nixos-option |
| Config not applied | Module not imported | Check imports in configuration.nix |
| SSoT not available | Registry module not loaded first | Ensure configs-registry is imported before dependent modules |

## Dependencies

- **Requires:** `00-principles.nix`, `01-configs-registry.nix` (and others per NIXMETA `requires`)
- **Required by:** Higher-domain modules that consume this service

## Maintenance

- **Log location:** `journalctl -u "zram-swap" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
