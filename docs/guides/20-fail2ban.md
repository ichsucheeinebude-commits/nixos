---
domain: 20
id: "NIXH-20-F2B-001"
title: "Fail2ban Intrusion Prevention — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [fail2ban, security]
description: "Fail2ban Intrusion Prevention module."
path: "root/guides/20-fail2ban.md"
links:
  adr: ADR-20-fail2ban.md
  guide: 20-fail2ban.md
  module: modules/20-security/20-fail2ban.nix
---

# "Fail2ban Intrusion Prevention"

**Domain:** 20-security
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-20-F2B-001"

---

## Overview

This module provides "fail2ban intrusion prevention" functionality for the NixOS system.
"Fail2ban Intrusion Prevention module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."fail2ban-intrusion-prevention".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "fail2ban-intrusion-prevention"

# Check config was applied
nixos-option my.services."fail2ban-intrusion-prevention".enable

# Check logs
journalctl -u "fail2ban-intrusion-prevention" -f --no-pager
```

## Known Failure Modes

| Symptom | Cause | Fix |
|---|---|---|
| Service not starting | Configuration error | Check journalctl for error messages |
| Port conflict | Another service using same port | Change port in my.ports |
| Permission denied | User/group not created | Verify user exists with correct UID/GID |

## Dependencies

- **Requires:** `00-principles.nix`, `01-configs-registry.nix` (and others per NIXMETA `requires`)
- **Required by:** Higher-domain modules that consume this service

## Maintenance

- **Log location:** `journalctl -u "fail2ban-intrusion-prevention" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
