---
domain: 70
id: "NIXH-70-FRG-001"
title: "Forgejo Git — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [forgejo, git]
description: "Operational guide for forgejo git."
path: "guides/70-forgejo.md"
links:
  adr: docs/adr/ADR-70-forgejo.md
  guide: docs/guides/70-forgejo.md
  module: modules/70-forge/70-forgejo.nix
---

# forgejo — Forgejo Git

**Domain:** 70  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides forgejo git.

## Configuration

```nix
my.services.forgejo.enable = true;
```

## Verification

```bash
systemctl status forgejo
nixos-option my.services.forgejo.enable
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

- **Logs:** `journalctl -u forgejo -f`
- **Reload:** `sudo nixos-rebuild switch`
