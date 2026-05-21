---
domain: 50
id: "NIXH-50-ARR-001"
title: "Arr Stack Common — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [arr, factory]
description: "Operational guide for arr stack common."
path: "guides/50-arr-stack.md"
links:
  adr: docs/adr/ADR-50-arr-stack.md
  guide: docs/guides/50-arr-stack.md
  module: modules/50-media/51-arr-stack.nix
---

# arr-stack — Arr Stack Common

**Domain:** 50  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides arr stack common.

## Configuration

```nix
my.services.arr_stack.enable = true;
```

## Verification

```bash
systemctl status arr-stack
nixos-option my.services.arr_stack.enable
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

- **Logs:** `journalctl -u arr-stack -f`
- **Reload:** `sudo nixos-rebuild switch`
