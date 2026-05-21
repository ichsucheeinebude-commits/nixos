---
domain: 40
id: "NIXH-40-UKM-001"
title: "Uptime Kuma — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [uptime, monitoring]
description: "Uptime Kuma module."
path: "root/guides/45-uptime-kuma.md"
links:
  adr: ADR-45-uptime-kuma.md
  guide: 45-uptime-kuma.md
  module: modules/40-monitoring/45-uptime-kuma.nix
---

# "Uptime Kuma"

**Domain:** 40-monitoring
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-40-UKM-001"

---

## Overview

This module provides "uptime kuma" functionality for the NixOS system.
"Uptime Kuma module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."uptime-kuma".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "uptime-kuma"

# Check config was applied
nixos-option my.services."uptime-kuma".enable

# Check logs
journalctl -u "uptime-kuma" -f --no-pager
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

- **Log location:** `journalctl -u "uptime-kuma" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
