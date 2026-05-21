---
domain: 00
id: "NIXH-00-COR-002"
title: "Identity & Hardware Registry — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,identity,hardware,registry,ports]
description: "Central registry for identity, hardware specs, network, and service toggles."
path: "root/guides/01-configs-registry.md"
links:
  adr: ADR-01-configs-registry.md
  guide: 01-configs-registry.md
  module: modules/00-core/01-configs-registry.nix
---

# "Identity & Hardware Registry"

**Domain:** 00-core
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-00-COR-002"

---

## Overview

This module provides "identity & hardware registry" functionality for the NixOS system.
"Central registry for identity, hardware specs, network, and service toggles."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."identity-&-hardware-registry".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "identity-&-hardware-registry"

# Check config was applied
nixos-option my.services."identity-&-hardware-registry".enable

# Check logs
journalctl -u "identity-&-hardware-registry" -f --no-pager
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

- **Log location:** `journalctl -u "identity-&-hardware-registry" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
