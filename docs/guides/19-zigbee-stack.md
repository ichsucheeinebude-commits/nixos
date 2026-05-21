---
domain: 10
id: "NIXH-10-ZIG-001"
title: "Zigbee/MQTT Stack — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [zigbee, mqtt]
description: "Zigbee/MQTT Stack module."
path: "root/guides/19-zigbee-stack.md"
links:
  adr: ADR-19-zigbee-stack.md
  guide: 19-zigbee-stack.md
  module: modules/10-network/19-zigbee-stack.nix
---

# "Zigbee/MQTT Stack"

**Domain:** 10-network
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-10-ZIG-001"

---

## Overview

This module provides "zigbee/mqtt stack" functionality for the NixOS system.
"Zigbee/MQTT Stack module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."zigbee/mqtt-stack".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "zigbee/mqtt-stack"

# Check config was applied
nixos-option my.services."zigbee/mqtt-stack".enable

# Check logs
journalctl -u "zigbee/mqtt-stack" -f --no-pager
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

- **Log location:** `journalctl -u "zigbee/mqtt-stack" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
