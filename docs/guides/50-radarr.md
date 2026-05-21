---
domain: 50
id: "NIXH-50-RAD-001"
title: "Radarr Movies — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [radarr, movies]
description: "Operational guide for radarr movies."
path: "guides/50-radarr.md"
links:
  adr: docs/adr/ADR-50-radarr.md
  guide: docs/guides/50-radarr.md
  module: modules/50-media/57-radarr.nix
---

# radarr — Radarr Movies

**Domain:** 50  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides radarr movies.

## Configuration

```nix
my.services.radarr.enable = true;
```

## Verification

```bash
systemctl status radarr
nixos-option my.services.radarr.enable
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

- **Logs:** `journalctl -u radarr -f`
- **Reload:** `sudo nixos-rebuild switch`
