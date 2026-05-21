---
domain: 00
id: "NIXH-00-COR-008"
title: "Locale & System — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,locale,timezone,keymap]
description: "System locale, timezone, and keymap configuration."
path: "root/guides/07-locale-system.md"
links:
  adr: ADR-07-locale-system.md
  guide: 07-locale-system.md
  module: modules/00-core/07-locale-system.nix
---

# "Locale & System"

**Domain:** 00-core
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-00-COR-008"

---

## Overview

This module provides "locale & system" functionality for the NixOS system.
"System locale, timezone, and keymap configuration."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."locale-&-system".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "locale-&-system"

# Check config was applied
nixos-option my.services."locale-&-system".enable

# Check logs
journalctl -u "locale-&-system" -f --no-pager
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

- **Log location:** `journalctl -u "locale-&-system" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
