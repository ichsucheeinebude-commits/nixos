---
domain: 10
id: "NIXH-10-ZIG-001"
title: "Zigbee/MQTT Stack — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [zigbee, mqtt]
description: "Operational guide for zigbee/mqtt stack."
path: "guides/10-zigbee-stack.md"
links:
  adr: docs/adr/ADR-10-zigbee-stack.md
  guide: docs/guides/10-zigbee-stack.md
  module: modules/10-network/19-zigbee-stack.nix
---

# zigbee-stack — Zigbee/MQTT Stack

**Domain:** 10  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides zigbee/mqtt stack.

## Configuration

```nix
my.services.zigbee_stack.enable = true;
```

## Verification

```bash
systemctl status zigbee-stack
nixos-option my.services.zigbee_stack.enable
```

## Known Failure Modes

| Symptom | Cause | Fix |
|---|---|---|
| Service fails to start | Port conflict | Change port |
| Exit code 127 | Binary missing | Run `nix flake update` |

## Dependencies

- **Requires:** See NIXMETA header
- **Required by:** Higher-domain modules

## Maintenance

- **Logs:** `journalctl -u zigbee-stack -f`
- **Reload:** `sudo nixos-rebuild switch`
