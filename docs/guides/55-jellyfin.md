---
domain: 50
id: "NIXH-50-JEL-001"
title: "Jellyfin Media Server — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [jellyfin, media]
description: "Jellyfin Media Server module."
path: "root/guides/55-jellyfin.md"
links:
  adr: ADR-55-jellyfin.md
  guide: 55-jellyfin.md
  module: modules/50-media/55-jellyfin.nix
---

# "Jellyfin Media Server"

**Domain:** 50-media
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-50-JEL-001"

---

## Overview

This module provides "jellyfin media server" functionality for the NixOS system.
"Jellyfin Media Server module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."jellyfin-media-server".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "jellyfin-media-server"

# Check config was applied
nixos-option my.services."jellyfin-media-server".enable

# Check logs
journalctl -u "jellyfin-media-server" -f --no-pager
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

- **Log location:** `journalctl -u "jellyfin-media-server" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
