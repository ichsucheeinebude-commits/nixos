---
domain: 60
id: "NIXH-60-KRK-001"
title: "Karakeep Bookmarks — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [karakeep, bookmarks]
description: "Operational guide for karakeep bookmarks."
path: "guides/60-karakeep.md"
links:
  adr: docs/adr/ADR-60-karakeep.md
  guide: docs/guides/60-karakeep.md
  module: modules/60-apps/69-karakeep.nix
---

# karakeep — Karakeep Bookmarks

**Domain:** 60  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides karakeep bookmarks.

## Configuration

```nix
my.services.karakeep.enable = true;
```

## Verification

```bash
systemctl status karakeep
nixos-option my.services.karakeep.enable
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

- **Logs:** `journalctl -u karakeep -f`
- **Reload:** `sudo nixos-rebuild switch`
