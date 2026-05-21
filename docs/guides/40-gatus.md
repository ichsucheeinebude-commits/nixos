---
domain: 40
id: "NIXH-40-GAT-001"
title: "Gatus Health Checks — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [gatus, monitoring]
description: "Gatus Health Checks module."
path: "root/guides/40-gatus.md"
links:
  adr: ADR-40-gatus.md
  guide: 40-gatus.md
  module: modules/40-monitoring/40-gatus.nix
---

# "Gatus Health Checks"

**Domain:** 40-monitoring
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-40-GAT-001"

---

## Overview

This module provides "gatus health checks" functionality for the NixOS system.
"Gatus Health Checks module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."gatus-health-checks".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "gatus-health-checks"

# Check config was applied
nixos-option my.services."gatus-health-checks".enable

# Check logs
journalctl -u "gatus-health-checks" -f --no-pager
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

- **Log location:** `journalctl -u "gatus-health-checks" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
