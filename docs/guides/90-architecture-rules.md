---
domain: 90
id: "NIXH-90-ARC-001"
title: "Architecture Rules — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [architecture, rules]
description: "Operational guide for architecture rules."
path: "guides/90-architecture-rules.md"
links:
  adr: docs/adr/ADR-90-architecture-rules.md
  guide: docs/guides/90-architecture-rules.md
  module: modules/90-policy/91-architecture-rules.nix
---

# architecture-rules — Architecture Rules

**Domain:** 90  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides architecture rules.

## Configuration

```nix
my.services.architecture_rules.enable = true;
```

## Verification

```bash
systemctl status architecture-rules
nixos-option my.services.architecture_rules.enable
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

- **Logs:** `journalctl -u architecture-rules -f`
- **Reload:** `sudo nixos-rebuild switch`
