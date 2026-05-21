---
domain: 00
id: "NIXH-00-COR-004"
title: "Hardware Profile — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,hardware,cpu,gpu,microcode]
description: "CPU microcode, GPU drivers, and hardware-specific configuration."
path: "root/guides/03-hardware-profile.md"
links:
  adr: ADR-03-hardware-profile.md
  guide: 03-hardware-profile.md
  module: modules/00-core/03-hardware-profile.nix
---

# "Hardware Profile"

**Domain:** 00-core
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-00-COR-004"

---

## Overview

This module provides "hardware profile" functionality for the NixOS system.
"CPU microcode, GPU drivers, and hardware-specific configuration."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."hardware-profile".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "hardware-profile"

# Check config was applied
nixos-option my.services."hardware-profile".enable

# Check logs
journalctl -u "hardware-profile" -f --no-pager
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

- **Log location:** `journalctl -u "hardware-profile" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
