---
domain: 60
id: "NIXH-60-LNK-001"
title: "Linkding Bookmarks — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [linkding, bookmarks]
description: "Operational guide for linkding bookmarks."
path: "guides/60-linkding.md"
links:
  adr: docs/adr/ADR-60-linkding.md
  guide: docs/guides/60-linkding.md
  module: modules/60-apps/67-linkding.nix
---

# linkding — Linkding Bookmarks

**Domain:** 60  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides linkding bookmarks.

## Configuration

```nix
my.services.linkding.enable = true;
```

## Verification

```bash
systemctl status linkding
nixos-option my.services.linkding.enable
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

- **Logs:** `journalctl -u linkding -f`
- **Reload:** `sudo nixos-rebuild switch`
