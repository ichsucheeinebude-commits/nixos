---
domain: 40
id: "NIXH-40-NTF-001"
title: "Ntfy Notifications — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [ntfy, notifications]
description: "Operational guide for ntfy notifications."
path: "guides/40-ntfy.md"
links:
  adr: docs/adr/ADR-40-ntfy.md
  guide: docs/guides/40-ntfy.md
  module: modules/40-monitoring/42-ntfy.nix
---

# ntfy — Ntfy Notifications

**Domain:** 40  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides ntfy notifications.

## Configuration

```nix
my.services.ntfy.enable = true;
```

## Verification

```bash
systemctl status ntfy
nixos-option my.services.ntfy.enable
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

- **Logs:** `journalctl -u ntfy -f`
- **Reload:** `sudo nixos-rebuild switch`
