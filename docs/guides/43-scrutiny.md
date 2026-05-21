---
domain: 40
id: "NIXH-40-SCR-001"
title: "Scrutiny SMART Monitor — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [scrutiny, smart]
description: "Scrutiny SMART Monitor module."
path: "root/guides/43-scrutiny.md"
links:
  adr: ADR-43-scrutiny.md
  guide: 43-scrutiny.md
  module: modules/40-monitoring/43-scrutiny.nix
---

# "Scrutiny SMART Monitor"

**Domain:** 40-monitoring
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-40-SCR-001"

---

## Overview

This module provides "scrutiny smart monitor" functionality for the NixOS system.
"Scrutiny SMART Monitor module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."scrutiny-smart-monitor".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "scrutiny-smart-monitor"

# Check config was applied
nixos-option my.services."scrutiny-smart-monitor".enable

# Check logs
journalctl -u "scrutiny-smart-monitor" -f --no-pager
```

## Known Failure Modes

| Symptom | Cause | Fix |
|---|---|---|
| Dashboard not accessible | Port mismatch | Check port config and Caddy vhost |
| No data visible | Service not collecting | Check service status and socket path |
| High resource usage | Limits too permissive | Tighten MemoryMax and CPUQuota |

## Dependencies

- **Requires:** `00-principles.nix`, `01-configs-registry.nix` (and others per NIXMETA `requires`)
- **Required by:** Higher-domain modules that consume this service

## Maintenance

- **Log location:** `journalctl -u "scrutiny-smart-monitor" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
