---
domain: 00
id: "NIXH-06-ZRAM-001"
title: "ZRAM Swap — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [zram, swap, memory, performance]
description: "ZRAM swap configuration for memory compression and performance."
path: "root/guides/06-zram-swap.md"
links:
  adr: ADR-06-zram-swap.md
  guide: 06-zram-swap.md
  module: modules/00-core/06-zram-swap.nix
---

# ZRAM Swap

**Domain:** 00-core
**Status:** Draft
**Complexity:** 1/5
**ID:** NIXH-06-ZRAM-001

---

## Overview

This module provides zram swap functionality for the NixOS system.
ZRAM swap configuration for memory compression and performance.
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
