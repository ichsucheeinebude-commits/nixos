---
domain: 60
id: "NIXH-60-RDK-001"
title: "Readeck — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [readeck, read-it-later]
description: "Operational guide for readeck."
path: "guides/60-readeck.md"
links:
  adr: docs/adr/ADR-60-readeck.md
  guide: docs/guides/60-readeck.md
  module: modules/60-apps/64-readeck.nix
---

# readeck — Readeck

**Domain:** 60  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides readeck.

## Configuration

```nix
my.services.readeck.enable = true;
```

## Verification

```bash
systemctl status readeck
nixos-option my.services.readeck.enable
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

- **Logs:** `journalctl -u readeck -f`
- **Reload:** `sudo nixos-rebuild switch`
