---
domain: 10
id: "NIXH-10-DNS-001"
title: "DNS Automation — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [dns, cloudflare]
description: "DNS Automation module."
path: "root/guides/16-dns-automation.md"
links:
  adr: ADR-16-dns-automation.md
  guide: 16-dns-automation.md
  module: modules/10-network/16-dns-automation.nix
---

# "DNS Automation"

**Domain:** 10-network
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-10-DNS-001"

---

## Overview

This module provides "dns automation" functionality for the NixOS system.
"DNS Automation module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."dns-automation".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "dns-automation"

# Check config was applied
nixos-option my.services."dns-automation".enable

# Check logs
journalctl -u "dns-automation" -f --no-pager
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

- **Log location:** `journalctl -u "dns-automation" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
