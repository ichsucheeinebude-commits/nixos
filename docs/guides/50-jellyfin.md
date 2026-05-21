---
domain: 50
id: "NIXH-50-JEL-001"
title: "Jellyfin Media Server — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [jellyfin, media]
description: "Operational guide for jellyfin media server."
path: "guides/50-jellyfin.md"
links:
  adr: docs/adr/ADR-50-jellyfin.md
  guide: docs/guides/50-jellyfin.md
  module: modules/50-media/55-jellyfin.nix
---

# jellyfin — Jellyfin Media Server

**Domain:** 50  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides jellyfin media server.

## Configuration

```nix
my.services.jellyfin.enable = true;
```

## Verification

```bash
systemctl status jellyfin
nixos-option my.services.jellyfin.enable
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

- **Logs:** `journalctl -u jellyfin -f`
- **Reload:** `sudo nixos-rebuild switch`
