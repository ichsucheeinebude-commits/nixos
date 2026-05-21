---
domain: 10
id: "NIXH-10-CDY-001"
title: "Caddy Reverse Proxy — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [caddy, proxy, tls]
description: "Operational guide for caddy reverse proxy."
path: "guides/10-caddy.md"
links:
  adr: docs/adr/ADR-10-caddy.md
  guide: docs/guides/10-caddy.md
  module: modules/10-network/15-caddy.nix
---

# caddy — Caddy Reverse Proxy

**Domain:** 10  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides caddy reverse proxy.

## Configuration

```nix
my.services.caddy.enable = true;
```

## Verification

```bash
systemctl status caddy
nixos-option my.services.caddy.enable
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

- **Logs:** `journalctl -u caddy -f`
- **Reload:** `sudo nixos-rebuild switch`
