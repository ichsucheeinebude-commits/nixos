---
domain: 10
id: "NIXH-10-BLK-001"
title: "Blocky DNS Filter — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [dns, blocky]
description: "Operational guide for blocky dns filter."
path: "guides/10-blocky.md"
links:
  adr: docs/adr/ADR-10-blocky.md
  guide: docs/guides/10-blocky.md
  module: modules/10-network/14-blocky.nix
---

# blocky — Blocky DNS Filter

**Domain:** 10  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides blocky dns filter.

## Configuration

```nix
my.services.blocky.enable = true;
```

## Verification

```bash
systemctl status blocky
nixos-option my.services.blocky.enable
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

- **Logs:** `journalctl -u blocky -f`
- **Reload:** `sudo nixos-rebuild switch`
