---
domain: 00
id: "NIXH-01-REG-001"
title: "SSoT Configs Registry — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [config, ssot, identity, paths]
description: "Single Source of Truth for identity, network, paths, and port assignments."
path: "root/guides/01-configs-registry.md"
links:
  adr: ADR-01-configs-registry.md
  guide: 01-configs-registry.md
  module: modules/00-core/01-configs-registry.nix
---

# SSoT Configs Registry

**Domain:** 00-core
**Status:** Draft
**Complexity:** 1/5
**ID:** NIXH-01-REG-001

---

## Overview

This module provides ssot configs registry functionality for the NixOS system.
Single Source of Truth for identity, network, paths, and port assignments.
As a 00-core module, it is evaluated before all domain-specific modules.

## Configuration

```nix
# Configuration is typically driven by my.configs SSoT registry
# Most options have sensible defaults
my.configs.identity.domain = "example.com";
```

## Verification

```bash
# Check config was applied
nixos-option my.configs

# Verify system state
systemctl status <service>
```

## Known Failure Modes

| Symptom | Cause | Fix |
|---|---|---|
| Config not applied | Module not imported in host config | Check imports in configuration.nix |
| Eval error | Conflicting option definitions | Check for duplicate definitions with nixos-option |
| SSoT not available | Configs registry module not loaded first | Ensure 01-configs-registry is imported before dependent modules |

## Dependencies

- **Requires:** Nothing (this is a 00-core module evaluated first)
- **Required by:** All modules in domains 10–90

## Maintenance

- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
