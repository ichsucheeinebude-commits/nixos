---
domain: 10
id: "NIXH-10-DDN-001"
title: "DDNS Updater — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [ddns, dynamic]
description: "Operational guide for ddns updater."
path: "guides/10-ddns-updater.md"
links:
  adr: docs/adr/ADR-10-ddns-updater.md
  guide: docs/guides/10-ddns-updater.md
  module: modules/10-network/18-ddns-updater.nix
---

# ddns-updater — DDNS Updater

**Domain:** 10  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides ddns updater.

## Configuration

```nix
my.services.ddns_updater.enable = true;
```

## Verification

```bash
systemctl status ddns-updater
nixos-option my.services.ddns_updater.enable
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

- **Logs:** `journalctl -u ddns-updater -f`
- **Reload:** `sudo nixos-rebuild switch`
