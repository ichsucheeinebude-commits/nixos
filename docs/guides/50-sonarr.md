---
domain: 50
id: "NIXH-50-SON-001"
title: "Sonarr TV — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [sonarr, tv]
description: "Operational guide for sonarr tv."
path: "guides/50-sonarr.md"
links:
  adr: docs/adr/ADR-50-sonarr.md
  guide: docs/guides/50-sonarr.md
  module: modules/50-media/56-sonarr.nix
---

# sonarr — Sonarr TV

**Domain:** 50  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides sonarr tv.

## Configuration

```nix
my.services.sonarr.enable = true;
```

## Verification

```bash
systemctl status sonarr
nixos-option my.services.sonarr.enable
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

- **Logs:** `journalctl -u sonarr -f`
- **Reload:** `sudo nixos-rebuild switch`
