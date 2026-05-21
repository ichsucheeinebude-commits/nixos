---
domain: 10
id: "NIXH-10-NET-002"
title: "NFTables Firewall — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,firewall,nftables]
description: "NFTables firewall with LAN trust and public port rules."
path: "root/guides/11-firewall.md"
links:
  adr: ADR-11-firewall.md
  guide: 11-firewall.md
  module: modules/10-network/11-firewall.nix
---

# "NFTables Firewall"

**Domain:** 10-network
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-10-NET-002"

---

## Overview

This module provides "nftables firewall" functionality for the NixOS system.
"NFTables firewall with LAN trust and public port rules."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."nftables-firewall".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "nftables-firewall"

# Check config was applied
nixos-option my.services."nftables-firewall".enable

# Check logs
journalctl -u "nftables-firewall" -f --no-pager
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

- **Log location:** `journalctl -u "nftables-firewall" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
