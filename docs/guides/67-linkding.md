---
domain: 60
id: "NIXH-60-LNK-001"
title: "Linkding Bookmarks — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [linkding, bookmarks]
description: "Linkding Bookmarks module."
path: "root/guides/67-linkding.md"
links:
  adr: ADR-67-linkding.md
  guide: 67-linkding.md
  module: modules/60-apps/67-linkding.nix
---

# "Linkding Bookmarks"

**Domain:** 60-apps
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-60-LNK-001"

---

## Overview

This module provides "linkding bookmarks" functionality for the NixOS system.
"Linkding Bookmarks module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."linkding-bookmarks".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "linkding-bookmarks"

# Check config was applied
nixos-option my.services."linkding-bookmarks".enable

# Check logs
journalctl -u "linkding-bookmarks" -f --no-pager
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

- **Log location:** `journalctl -u "linkding-bookmarks" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
