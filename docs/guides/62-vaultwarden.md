---
domain: 60
id: "NIXH-60-VLT-001"
title: "Vaultwarden Passwords — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [vaultwarden, passwords]
description: "Vaultwarden Passwords module."
path: "root/guides/62-vaultwarden.md"
links:
  adr: ADR-62-vaultwarden.md
  guide: 62-vaultwarden.md
  module: modules/60-apps/62-vaultwarden.nix
---

# "Vaultwarden Passwords"

**Domain:** 60-apps
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-60-VLT-001"

---

## Overview

This module provides "vaultwarden passwords" functionality for the NixOS system.
"Vaultwarden Passwords module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."vaultwarden-passwords".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "vaultwarden-passwords"

# Check config was applied
nixos-option my.services."vaultwarden-passwords".enable

# Check logs
journalctl -u "vaultwarden-passwords" -f --no-pager
```

## Known Failure Modes

| Symptom | Cause | Fix |
|---|---|---|
| Service not starting | Database not initialized | Check PostgreSQL status and SOPS secrets |
| SSO login fails | Caddy forward auth misconfigured | Verify Caddy vhost and Pocket-ID |
| Data loss after reboot | StateDir not persistent | Add to my.persistence.directories |

## Dependencies

- **Requires:** `00-principles.nix`, `01-configs-registry.nix` (and others per NIXMETA `requires`)
- **Required by:** Higher-domain modules that consume this service

## Maintenance

- **Log location:** `journalctl -u "vaultwarden-passwords" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
