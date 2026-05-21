---
domain: 60
id: "NIXH-60-MNC-001"
title: "Monica CRM — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [monica, crm]
description: "Monica CRM module."
path: "root/guides/68-monica.md"
links:
  adr: ADR-68-monica.md
  guide: 68-monica.md
  module: modules/60-apps/68-monica.nix
---

# "Monica CRM"

**Domain:** 60-apps
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-60-MNC-001"

---

## Overview

This module provides "monica crm" functionality for the NixOS system.
"Monica CRM module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."monica-crm".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "monica-crm"

# Check config was applied
nixos-option my.services."monica-crm".enable

# Check logs
journalctl -u "monica-crm" -f --no-pager
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

- **Log location:** `journalctl -u "monica-crm" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
