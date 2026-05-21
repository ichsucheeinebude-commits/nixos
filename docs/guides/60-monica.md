---
domain: 60
id: "NIXH-60-MNC-001"
title: "Monica CRM — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [monica, crm]
description: "Operational guide for monica crm."
path: "guides/60-monica.md"
links:
  adr: docs/adr/ADR-60-monica.md
  guide: docs/guides/60-monica.md
  module: modules/60-apps/68-monica.nix
---

# monica — Monica CRM

**Domain:** 60  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides monica crm.

## Configuration

```nix
my.services.monica.enable = true;
```

## Verification

```bash
systemctl status monica
nixos-option my.services.monica.enable
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

- **Logs:** `journalctl -u monica -f`
- **Reload:** `sudo nixos-rebuild switch`
