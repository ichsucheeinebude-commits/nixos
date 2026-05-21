---
domain: 10
id: "NIXH-10-PID-001"
title: "Pocket-ID OIDC — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [oidc, auth]
description: "Pocket-ID OIDC module."
path: "root/guides/17-pocket-id.md"
links:
  adr: ADR-17-pocket-id.md
  guide: 17-pocket-id.md
  module: modules/10-network/17-pocket-id.nix
---

# "Pocket-ID OIDC"

**Domain:** 10-network
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-10-PID-001"

---

## Overview

This module provides "pocket-id oidc" functionality for the NixOS system.
"Pocket-ID OIDC module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."pocket-id-oidc".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "pocket-id-oidc"

# Check config was applied
nixos-option my.services."pocket-id-oidc".enable

# Check logs
journalctl -u "pocket-id-oidc" -f --no-pager
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

- **Log location:** `journalctl -u "pocket-id-oidc" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
