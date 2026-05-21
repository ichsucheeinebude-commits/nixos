---
domain: 40
id: "NIXH-40-VEC-001"
title: "Vector Log Pipeline — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [vector, logs]
description: "Operational guide for vector log pipeline."
path: "guides/40-vector.md"
links:
  adr: docs/adr/ADR-40-vector.md
  guide: docs/guides/40-vector.md
  module: modules/40-monitoring/44-vector.nix
---

# vector — Vector Log Pipeline

**Domain:** 40  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides vector log pipeline.

## Configuration

```nix
my.services.vector.enable = true;
```

## Verification

```bash
systemctl status vector
nixos-option my.services.vector.enable
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

- **Logs:** `journalctl -u vector -f`
- **Reload:** `sudo nixos-rebuild switch`
