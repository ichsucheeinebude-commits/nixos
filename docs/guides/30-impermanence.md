---
domain: 30
id: "NIXH-30-IMP-001"
title: "Impermanence — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [impermanence, erase]
description: "Operational guide for impermanence."
path: "guides/30-impermanence.md"
links:
  adr: docs/adr/ADR-30-impermanence.md
  guide: docs/guides/30-impermanence.md
  module: modules/30-storage/32-impermanence.nix
---

# impermanence — Impermanence

**Domain:** 30  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides impermanence.

## Configuration

```nix
my.services.impermanence.enable = true;
```

## Verification

```bash
systemctl status impermanence
nixos-option my.services.impermanence.enable
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

- **Logs:** `journalctl -u impermanence -f`
- **Reload:** `sudo nixos-rebuild switch`
