---
domain: 40
id: "NIXH-40-UKM-001"
title: "Uptime Kuma — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [uptime, monitoring]
description: "Operational guide for uptime kuma."
path: "guides/40-uptime-kuma.md"
links:
  adr: docs/adr/ADR-40-uptime-kuma.md
  guide: docs/guides/40-uptime-kuma.md
  module: modules/40-monitoring/45-uptime-kuma.nix
---

# uptime-kuma — Uptime Kuma

**Domain:** 40  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides uptime kuma.

## Configuration

```nix
my.services.uptime_kuma.enable = true;
```

## Verification

```bash
systemctl status uptime-kuma
nixos-option my.services.uptime_kuma.enable
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

- **Logs:** `journalctl -u uptime-kuma -f`
- **Reload:** `sudo nixos-rebuild switch`
