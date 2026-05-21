---
domain: 00
id: "NIXH-00-COR-001"
title: "Principles & Defaults — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,principles,bastelmodus]
description: "Global toggle and experimental flag for the entire boilerplate."
path: "root/guides/00-principles.md"
links:
  adr: ADR-00-principles.md
  guide: 00-principles.md
  module: modules/00-core/00-principles.nix
---

# "Principles & Defaults"

**Domain:** 00-core
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-00-COR-001"

---

## Overview

This module provides "principles & defaults" functionality for the NixOS system.
"Global toggle and experimental flag for the entire boilerplate."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."principles-&-defaults".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "principles-&-defaults"

# Check config was applied
nixos-option my.services."principles-&-defaults".enable

# Check logs
journalctl -u "principles-&-defaults" -f --no-pager
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

- **Log location:** `journalctl -u "principles-&-defaults" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
