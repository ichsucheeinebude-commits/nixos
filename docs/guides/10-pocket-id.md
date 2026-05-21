---
domain: 10
id: "NIXH-10-PID-001"
title: "Pocket-ID OIDC — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [oidc, auth]
description: "Operational guide for pocket-id oidc."
path: "guides/10-pocket-id.md"
links:
  adr: docs/adr/ADR-10-pocket-id.md
  guide: docs/guides/10-pocket-id.md
  module: modules/10-network/17-pocket-id.nix
---

# pocket-id — Pocket-ID OIDC

**Domain:** 10  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides pocket-id oidc.

## Configuration

```nix
my.services.pocket_id.enable = true;
```

## Verification

```bash
systemctl status pocket-id
nixos-option my.services.pocket_id.enable
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

- **Logs:** `journalctl -u pocket-id -f`
- **Reload:** `sudo nixos-rebuild switch`
