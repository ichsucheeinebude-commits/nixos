---
domain: 50
id: "NIXH-50-PRO-001"
title: "Prowlarr Indexer — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [prowlarr, indexer]
description: "Operational guide for prowlarr indexer."
path: "guides/50-prowlarr.md"
links:
  adr: docs/adr/ADR-50-prowlarr.md
  guide: docs/guides/50-prowlarr.md
  module: modules/50-media/58-prowlarr.nix
---

# prowlarr — Prowlarr Indexer

**Domain:** 50  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides prowlarr indexer.

## Configuration

```nix
my.services.prowlarr.enable = true;
```

## Verification

```bash
systemctl status prowlarr
nixos-option my.services.prowlarr.enable
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

- **Logs:** `journalctl -u prowlarr -f`
- **Reload:** `sudo nixos-rebuild switch`
