---
domain: 40
id: "NIXH-40-GAT-001"
title: "Gatus Health Checks — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [gatus, monitoring]
description: "Operational guide for gatus health checks."
path: "guides/40-gatus.md"
links:
  adr: docs/adr/ADR-40-gatus.md
  guide: docs/guides/40-gatus.md
  module: modules/40-monitoring/40-gatus.nix
---

# gatus — Gatus Health Checks

**Domain:** 40  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides gatus health checks.

## Configuration

```nix
my.services.gatus.enable = true;
```

## Verification

```bash
systemctl status gatus
nixos-option my.services.gatus.enable
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

- **Logs:** `journalctl -u gatus -f`
- **Reload:** `sudo nixos-rebuild switch`
