---
domain: 40
id: "NIXH-40-SCR-001"
title: "Scrutiny SMART Monitor — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [scrutiny, smart]
description: "Operational guide for scrutiny smart monitor."
path: "guides/40-scrutiny.md"
links:
  adr: docs/adr/ADR-40-scrutiny.md
  guide: docs/guides/40-scrutiny.md
  module: modules/40-monitoring/43-scrutiny.nix
---

# scrutiny — Scrutiny SMART Monitor

**Domain:** 40  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides scrutiny smart monitor.

## Configuration

```nix
my.services.scrutiny.enable = true;
```

## Verification

```bash
systemctl status scrutiny
nixos-option my.services.scrutiny.enable
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

- **Logs:** `journalctl -u scrutiny -f`
- **Reload:** `sudo nixos-rebuild switch`
