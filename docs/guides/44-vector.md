---
domain: 40
id: "NIXH-40-VEC-001"
title: "Vector Log Pipeline — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [vector, logs]
description: "Vector Log Pipeline module."
path: "root/guides/44-vector.md"
links:
  adr: ADR-44-vector.md
  guide: 44-vector.md
  module: modules/40-monitoring/44-vector.nix
---

# "Vector Log Pipeline"

**Domain:** 40-monitoring
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-40-VEC-001"

---

## Overview

This module provides "vector log pipeline" functionality for the NixOS system.
"Vector Log Pipeline module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."vector-log-pipeline".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "vector-log-pipeline"

# Check config was applied
nixos-option my.services."vector-log-pipeline".enable

# Check logs
journalctl -u "vector-log-pipeline" -f --no-pager
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

- **Log location:** `journalctl -u "vector-log-pipeline" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
