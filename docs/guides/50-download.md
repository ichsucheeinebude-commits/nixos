---
domain: 50
id: "NIXH-50-DWN-001"
title: "Download Stack — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [download, usenet]
description: "Operational guide for download stack."
path: "guides/50-download.md"
links:
  adr: docs/adr/ADR-50-download.md
  guide: docs/guides/50-download.md
  module: modules/50-media/52-download.nix
---

# download — Download Stack

**Domain:** 50  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides download stack.

## Configuration

```nix
my.services.download.enable = true;
```

## Verification

```bash
systemctl status download
nixos-option my.services.download.enable
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

- **Logs:** `journalctl -u download -f`
- **Reload:** `sudo nixos-rebuild switch`
