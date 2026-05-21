---
domain: 00
id: "NIXH-00-COR-003"
title: "Nix Tuning — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,nix,gc,optimization]
description: "Nix daemon tuning, GC settings, and build optimization."
path: "root/guides/02-nix-tuning.md"
links:
  adr: ADR-02-nix-tuning.md
  guide: 02-nix-tuning.md
  module: modules/00-core/02-nix-tuning.nix
---

# "Nix Tuning"

**Domain:** 00-core
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-00-COR-003"

---

## Overview

This module provides "nix tuning" functionality for the NixOS system.
"Nix daemon tuning, GC settings, and build optimization."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."nix-tuning".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "nix-tuning"

# Check config was applied
nixos-option my.services."nix-tuning".enable

# Check logs
journalctl -u "nix-tuning" -f --no-pager
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

- **Log location:** `journalctl -u "nix-tuning" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
