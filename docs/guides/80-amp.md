---
domain: 80
id: "NIXH-80-AMP-001"
title: "AMP Gaming — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [amp, gaming]
description: "Operational guide for amp gaming."
path: "guides/80-amp.md"
links:
  adr: docs/adr/ADR-80-amp.md
  guide: docs/guides/80-amp.md
  module: modules/80-gaming/80-amp.nix
---

# amp — AMP Gaming

**Domain:** 80  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides amp gaming.

## Configuration

```nix
my.services.amp.enable = true;
```

## Verification

```bash
systemctl status amp
nixos-option my.services.amp.enable
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

- **Logs:** `journalctl -u amp -f`
- **Reload:** `sudo nixos-rebuild switch`
