---
domain: 00
id: "NIXH-00-COR-005"
title: "Boot Safeguards — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,boot,memtest,safeguards]
description: "Boot configuration limits, memtest entry, and generation pruning."
path: "root/guides/04-boot-safeguards.md"
links:
  adr: ADR-04-boot-safeguards.md
  guide: 04-boot-safeguards.md
  module: modules/00-core/04-boot-safeguards.nix
---

# "Boot Safeguards"

**Domain:** 00-core
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-00-COR-005"

---

## Overview

This module provides "boot safeguards" functionality for the NixOS system.
"Boot configuration limits, memtest entry, and generation pruning."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."boot-safeguards".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "boot-safeguards"

# Check config was applied
nixos-option my.services."boot-safeguards".enable

# Check logs
journalctl -u "boot-safeguards" -f --no-pager
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

- **Log location:** `journalctl -u "boot-safeguards" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
