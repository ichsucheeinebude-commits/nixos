---
domain: 10
id: "NIXH-10-NET-004"
title: "SSH Rescue — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,ssh,rescue]
description: "Secondary SSH service for emergency access."
path: "root/guides/13-ssh-rescue.md"
links:
  adr: ADR-13-ssh-rescue.md
  guide: 13-ssh-rescue.md
  module: modules/10-network/13-ssh-rescue.nix
---

# "SSH Rescue"

**Domain:** 10-network
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-10-NET-004"

---

## Overview

This module provides "ssh rescue" functionality for the NixOS system.
"Secondary SSH service for emergency access."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."ssh-rescue".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "ssh-rescue"

# Check config was applied
nixos-option my.services."ssh-rescue".enable

# Check logs
journalctl -u "ssh-rescue" -f --no-pager
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

- **Log location:** `journalctl -u "ssh-rescue" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
