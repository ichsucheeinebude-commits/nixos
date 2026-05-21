---
domain: 10
id: "NIXH-10-DDN-001"
title: "DDNS Updater — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [ddns, dynamic]
description: "DDNS Updater module."
path: "root/guides/18-ddns-updater.md"
links:
  adr: ADR-18-ddns-updater.md
  guide: 18-ddns-updater.md
  module: modules/10-network/18-ddns-updater.nix
---

# "DDNS Updater"

**Domain:** 10-network
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-10-DDN-001"

---

## Overview

This module provides "ddns updater" functionality for the NixOS system.
"DDNS Updater module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."ddns-updater".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "ddns-updater"

# Check config was applied
nixos-option my.services."ddns-updater".enable

# Check logs
journalctl -u "ddns-updater" -f --no-pager
```

## Known Failure Modes

| Symptom | Cause | Fix |
|---|---|---|
| Service not starting | Configuration error | Check journalctl for error messages |
| Port conflict | Another service using same port | Change port in my.ports configuration |
| Network unreachable | Interface not matched | Check match config and verify with `ip link` |

## Dependencies

- **Requires:** `00-principles.nix`, `01-configs-registry.nix` (and others per NIXMETA `requires`)
- **Required by:** Higher-domain modules that consume this service

## Maintenance

- **Log location:** `journalctl -u "ddns-updater" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
