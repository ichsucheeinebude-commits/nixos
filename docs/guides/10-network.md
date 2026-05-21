---
domain: 10
id: "NIXH-10-NET-001"
title: "Network Configuration — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,systemd-resolved]
description: "Base networking: systemd-resolved, DNS servers, host name."
path: "root/guides/10-network.md"
links:
  adr: ADR-10-network.md
  guide: 10-network.md
  module: modules/10-network/10-network.nix
---

# "Network Configuration"

**Domain:** 10-network
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-10-NET-001"

---

## Overview

This module provides "network configuration" functionality for the NixOS system.
"Base networking: systemd-resolved, DNS servers, host name."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."network-configuration".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "network-configuration"

# Check config was applied
nixos-option my.services."network-configuration".enable

# Check logs
journalctl -u "network-configuration" -f --no-pager
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

- **Log location:** `journalctl -u "network-configuration" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
