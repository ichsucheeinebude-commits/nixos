---
domain: 80
id: "NIXH-80-AMF-001"
title: "AMP FHS Wrapper — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [amp, fhs]
description: "Operational guide for amp fhs wrapper."
path: "guides/80-amp-fhs.md"
links:
  adr: docs/adr/ADR-80-amp-fhs.md
  guide: docs/guides/80-amp-fhs.md
  module: modules/80-gaming/81-amp-fhs.nix
---

# amp-fhs — AMP FHS Wrapper

**Domain:** 80  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides amp fhs wrapper.

## Configuration

```nix
my.services.amp_fhs.enable = true;
```

## Verification

```bash
systemctl status amp-fhs
nixos-option my.services.amp_fhs.enable
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

- **Logs:** `journalctl -u amp-fhs -f`
- **Reload:** `sudo nixos-rebuild switch`
