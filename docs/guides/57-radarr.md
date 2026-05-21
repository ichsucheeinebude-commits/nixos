---
domain: 50
id: "NIXH-50-RAD-001"
title: "Radarr Movies — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [radarr, movies]
description: "Radarr Movies module."
path: "root/guides/57-radarr.md"
links:
  adr: ADR-57-radarr.md
  guide: 57-radarr.md
  module: modules/50-media/57-radarr.nix
---

# "Radarr Movies"

**Domain:** 50-media
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-50-RAD-001"

---

## Overview

This module provides "radarr movies" functionality for the NixOS system.
"Radarr Movies module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."radarr-movies".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "radarr-movies"

# Check config was applied
nixos-option my.services."radarr-movies".enable

# Check logs
journalctl -u "radarr-movies" -f --no-pager
```

## Known Failure Modes

| Symptom | Cause | Fix |
|---|---|---|
| Service not starting | Missing API key | Check SOPS secrets and journalctl |
| Transcoding fails | GPU passthrough not configured | Verify hardware.graphics.enable and /dev/dri |
| Library scan slow | HDD access during scan | Schedule scans during low-activity window |

## Dependencies

- **Requires:** `00-principles.nix`, `01-configs-registry.nix` (and others per NIXMETA `requires`)
- **Required by:** Higher-domain modules that consume this service

## Maintenance

- **Log location:** `journalctl -u "radarr-movies" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
