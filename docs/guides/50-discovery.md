---
domain: 50
id: "NIXH-50-DIS-001"
title: "Media Discovery — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [discovery, jellyseerr]
description: "Operational guide for media discovery."
path: "guides/50-discovery.md"
links:
  adr: docs/adr/ADR-50-discovery.md
  guide: docs/guides/50-discovery.md
  module: modules/50-media/54-discovery.nix
---

# discovery — Media Discovery

**Domain:** 50  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides media discovery.

## Configuration

```nix
my.services.discovery.enable = true;
```

## Verification

```bash
systemctl status discovery
nixos-option my.services.discovery.enable
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

- **Logs:** `journalctl -u discovery -f`
- **Reload:** `sudo nixos-rebuild switch`
