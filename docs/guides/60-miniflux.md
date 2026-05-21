---
domain: 60
id: "NIXH-60-MNF-001"
title: "Miniflux RSS — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [miniflux, rss]
description: "Operational guide for miniflux rss."
path: "guides/60-miniflux.md"
links:
  adr: docs/adr/ADR-60-miniflux.md
  guide: docs/guides/60-miniflux.md
  module: modules/60-apps/66-miniflux.nix
---

# miniflux — Miniflux RSS

**Domain:** 60  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides miniflux rss.

## Configuration

```nix
my.services.miniflux.enable = true;
```

## Verification

```bash
systemctl status miniflux
nixos-option my.services.miniflux.enable
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

- **Logs:** `journalctl -u miniflux -f`
- **Reload:** `sudo nixos-rebuild switch`
