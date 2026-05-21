---
domain: 40
id: "NIXH-40-NTF-001"
title: "Ntfy Notifications — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [ntfy, notifications]
description: "Ntfy Notifications module."
path: "root/guides/42-ntfy.md"
links:
  adr: ADR-42-ntfy.md
  guide: 42-ntfy.md
  module: modules/40-monitoring/42-ntfy.nix
---

# "Ntfy Notifications"

**Domain:** 40-monitoring
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-40-NTF-001"

---

## Overview

This module provides "ntfy notifications" functionality for the NixOS system.
"Ntfy Notifications module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."ntfy-notifications".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "ntfy-notifications"

# Check config was applied
nixos-option my.services."ntfy-notifications".enable

# Check logs
journalctl -u "ntfy-notifications" -f --no-pager
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

- **Log location:** `journalctl -u "ntfy-notifications" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
