---
domain: 50
id: "NIXH-50-MLB-001"
title: "Media Library Base — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [media, library]
description: "Operational guide for media library base."
path: "guides/50-lib-media.md"
links:
  adr: docs/adr/ADR-50-lib-media.md
  guide: docs/guides/50-lib-media.md
  module: modules/50-media/50-lib-media.nix
---

# lib-media — Media Library Base

**Domain:** 50  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides media library base.

## Configuration

```nix
my.services.lib_media.enable = true;
```

## Verification

```bash
systemctl status lib-media
nixos-option my.services.lib_media.enable
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

- **Logs:** `journalctl -u lib-media -f`
- **Reload:** `sudo nixos-rebuild switch`
