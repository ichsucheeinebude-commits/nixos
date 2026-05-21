---
domain: 00
id: "NIXH-00-COR-009"
title: "Users & Groups — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,users,groups]
description: "System user and group definitions (no shell aliases)."
path: "root/guides/08-users-shell.md"
links:
  adr: ADR-08-users-shell.md
  guide: 08-users-shell.md
  module: modules/00-core/08-users-shell.nix
---

# "Users & Groups"

**Domain:** 00-core
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-00-COR-009"

---

## Overview

This module provides "users & groups" functionality for the NixOS system.
"System user and group definitions (no shell aliases)."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."users-&-groups".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "users-&-groups"

# Check config was applied
nixos-option my.services."users-&-groups".enable

# Check logs
journalctl -u "users-&-groups" -f --no-pager
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

- **Log location:** `journalctl -u "users-&-groups" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
