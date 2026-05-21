---
domain: 60
id: "NIXH-60-HAS-001"
title: "Home Assistant — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [home-assistant, iot]
description: "Home Assistant module."
path: "root/guides/63-home-assistant.md"
links:
  adr: ADR-63-home-assistant.md
  guide: 63-home-assistant.md
  module: modules/60-apps/63-home-assistant.nix
---

# "Home Assistant"

**Domain:** 60-apps
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-60-HAS-001"

---

## Overview

This module provides "home assistant" functionality for the NixOS system.
"Home Assistant module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."home-assistant".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "home-assistant"

# Check config was applied
nixos-option my.services."home-assistant".enable

# Check logs
journalctl -u "home-assistant" -f --no-pager
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

- **Log location:** `journalctl -u "home-assistant" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
