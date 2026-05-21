---
domain: 10
id: "NIXH-10-NET-003"
title: "SSH Server — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,ssh,openssh]
description: "OpenSSH server configuration."
path: "root/guides/12-ssh.md"
links:
  adr: ADR-12-ssh.md
  guide: 12-ssh.md
  module: modules/10-network/12-ssh.nix
---

# "SSH Server"

**Domain:** 10-network
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-10-NET-003"

---

## Overview

This module provides "ssh server" functionality for the NixOS system.
"OpenSSH server configuration."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."ssh-server".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "ssh-server"

# Check config was applied
nixos-option my.services."ssh-server".enable

# Check logs
journalctl -u "ssh-server" -f --no-pager
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

- **Log location:** `journalctl -u "ssh-server" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
