---
domain: 10
id: "NIXH-10-FWL-001"
title: "Nftables Firewall — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [firewall, nftables]
description: "Operational guide for nftables firewall."
path: "guides/10-firewall.md"
links:
  adr: docs/adr/ADR-10-firewall.md
  guide: docs/guides/10-firewall.md
  module: modules/10-network/11-firewall.nix
---

# firewall — Nftables Firewall

**Domain:** 10  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides nftables firewall.

## Configuration

```nix
my.services.firewall.enable = true;
```

## Verification

```bash
systemctl status firewall
nixos-option my.services.firewall.enable
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

- **Logs:** `journalctl -u firewall -f`
- **Reload:** `sudo nixos-rebuild switch`
