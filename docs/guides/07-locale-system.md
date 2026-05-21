---
domain: 00
id: "NIXH-07-LOC-001"
title: "Locale & System — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [locale, system, i18n, console]
description: "System locale, console font, keyboard layout, and NTP configuration."
path: "root/guides/07-locale-system.md"
links:
  adr: ADR-07-locale-system.md
  guide: 07-locale-system.md
  module: modules/00-core/07-locale-system.nix
---

# Locale & System

**Domain:** 00-core
**Status:** Draft
**Complexity:** 1/5
**ID:** NIXH-07-LOC-001

---

## Overview

This module provides locale & system functionality for the NixOS system.
System locale, console font, keyboard layout, and NTP configuration.
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
