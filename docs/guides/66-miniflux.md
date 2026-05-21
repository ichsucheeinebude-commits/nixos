---
domain: 60
id: "NIXH-60-MNF-001"
title: "Miniflux RSS — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [miniflux, rss]
description: "Miniflux RSS module."
path: "root/guides/66-miniflux.md"
links:
  adr: ADR-66-miniflux.md
  guide: 66-miniflux.md
  module: modules/60-apps/66-miniflux.nix
---

# "Miniflux RSS"

**Domain:** 60-apps
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-60-MNF-001"

---

## Overview

This module provides "miniflux rss" functionality for the NixOS system.
"Miniflux RSS module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."miniflux-rss".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "miniflux-rss"

# Check config was applied
nixos-option my.services."miniflux-rss".enable

# Check logs
journalctl -u "miniflux-rss" -f --no-pager
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

- **Log location:** `journalctl -u "miniflux-rss" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
