---
domain: 50
id: "NIXH-50-STR-001"
title: "Streaming Stack — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [streaming, jellyfin]
description: "Operational guide for streaming stack."
path: "guides/50-streaming.md"
links:
  adr: docs/adr/ADR-50-streaming.md
  guide: docs/guides/50-streaming.md
  module: modules/50-media/53-streaming.nix
---

# streaming — Streaming Stack

**Domain:** 50  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides streaming stack.

## Configuration

```nix
my.services.streaming.enable = true;
```

## Verification

```bash
systemctl status streaming
nixos-option my.services.streaming.enable
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

- **Logs:** `journalctl -u streaming -f`
- **Reload:** `sudo nixos-rebuild switch`
