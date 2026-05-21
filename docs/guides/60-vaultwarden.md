---
domain: 60
id: "NIXH-60-VLT-001"
title: "Vaultwarden Passwords — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [vaultwarden, passwords]
description: "Operational guide for vaultwarden passwords."
path: "guides/60-vaultwarden.md"
links:
  adr: docs/adr/ADR-60-vaultwarden.md
  guide: docs/guides/60-vaultwarden.md
  module: modules/60-apps/62-vaultwarden.nix
---

# vaultwarden — Vaultwarden Passwords

**Domain:** 60  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides vaultwarden passwords.

## Configuration

```nix
my.services.vaultwarden.enable = true;
```

## Verification

```bash
systemctl status vaultwarden
nixos-option my.services.vaultwarden.enable
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

- **Logs:** `journalctl -u vaultwarden -f`
- **Reload:** `sudo nixos-rebuild switch`
