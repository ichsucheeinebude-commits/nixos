---
domain: 10
id: "NIXH-10-NET-006"
title: "Caddy Reverse Proxy — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,caddy,reverse-proxy]
description: "Caddy as reverse proxy with automatic TLS."
path: "root/guides/15-caddy.md"
links:
  adr: ADR-15-caddy.md
  guide: 15-caddy.md
  module: modules/10-network/15-caddy.nix
---

# "Caddy Reverse Proxy"

**Domain:** 10-network
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-10-NET-006"

---

## Overview

This module provides "caddy reverse proxy" functionality for the NixOS system.
"Caddy as reverse proxy with automatic TLS."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."caddy-reverse-proxy".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "caddy-reverse-proxy"

# Check config was applied
nixos-option my.services."caddy-reverse-proxy".enable

# Check logs
journalctl -u "caddy-reverse-proxy" -f --no-pager
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

- **Log location:** `journalctl -u "caddy-reverse-proxy" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
