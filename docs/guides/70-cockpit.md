---
domain: 70
id: "NIXH-70-CKP-001"
title: "Cockpit Web Admin — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [cockpit, admin]
description: "Operational guide for cockpit web admin."
path: "guides/70-cockpit.md"
links:
  adr: docs/adr/ADR-70-cockpit.md
  guide: docs/guides/70-cockpit.md
  module: modules/70-forge/72-cockpit.nix
---

# cockpit — Cockpit Web Admin

**Domain:** 70  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides cockpit web admin.

## Configuration

```nix
my.services.cockpit.enable = true;
```

## Verification

```bash
systemctl status cockpit
nixos-option my.services.cockpit.enable
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

- **Logs:** `journalctl -u cockpit -f`
- **Reload:** `sudo nixos-rebuild switch`
