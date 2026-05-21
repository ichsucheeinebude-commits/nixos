---
domain: 10
id: "NIXH-10-NET-005"
title: "Blocky DNS — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,dns,blocky]
description: "Blocky DNS server with ad-blocking."
path: "root/guides/14-blocky.md"
links:
  adr: ADR-14-blocky.md
  guide: 14-blocky.md
  module: modules/10-network/14-blocky.nix
---

# "Blocky DNS"

**Domain:** 10-network
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-10-NET-005"

---

## Overview

This module provides "blocky dns" functionality for the NixOS system.
"Blocky DNS server with ad-blocking."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."blocky-dns".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "blocky-dns"

# Check config was applied
nixos-option my.services."blocky-dns".enable

# Check logs
journalctl -u "blocky-dns" -f --no-pager
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

- **Log location:** `journalctl -u "blocky-dns" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
