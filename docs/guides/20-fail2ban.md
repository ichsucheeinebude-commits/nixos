---
domain: 20
id: "NIXH-20-F2B-001"
title: "Fail2ban Intrusion Prevention — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [fail2ban, security]
description: "Operational guide for fail2ban intrusion prevention."
path: "guides/20-fail2ban.md"
links:
  adr: docs/adr/ADR-20-fail2ban.md
  guide: docs/guides/20-fail2ban.md
  module: modules/20-security/20-fail2ban.nix
---

# fail2ban — Fail2ban Intrusion Prevention

**Domain:** 20  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides fail2ban intrusion prevention.

## Configuration

```nix
my.services.fail2ban.enable = true;
```

## Verification

```bash
systemctl status fail2ban
nixos-option my.services.fail2ban.enable
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

- **Logs:** `journalctl -u fail2ban -f`
- **Reload:** `sudo nixos-rebuild switch`
