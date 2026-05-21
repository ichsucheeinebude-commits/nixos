---
domain: 50
id: "NIXH-59-LID-001"
title: "Lidarr Music Downloader — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [media, lidarr, music, automation]
description: "Lidarr for automated music downloading and library management."
path: "root/guides/59-lidarr.md"
links:
  adr: ADR-59-lidarr.md
  guide: 59-lidarr.md
  module: modules/50-media/59-lidarr.nix
---

# Lidarr Music Downloader

**Domain:** 50-media
**Status:** Draft
**Complexity:** 1/5
**ID:** NIXH-59-LID-001

---

## Overview

This module provides lidarr music downloader functionality for the NixOS system.
Lidarr for automated music downloading and library management.
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
my.services.lidarr-music-downloader.enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.

## Verification

```bash
systemctl status lidarr-music-downloader
nixos-option my.services.lidarr-music-downloader.enable
journalctl -u lidarr-music-downloader -f --no-pager
```

## Known Failure Modes

| Symptom | Cause | Fix |
|---|---|---|
| Service not starting | Missing API key | Check SOPS secrets and journalctl |
| Library scan fails | Music directory not mounted | Verify /mnt/media/music path |
| Download not working | Download client not connected | Check download client settings in Lidarr |

## Dependencies

- **Requires:** `00-principles.nix`, `01-configs-registry.nix`
- **Required by:** Higher-domain modules that consume this service

## Maintenance

- **Log location:** `journalctl -u lidarr-music-downloader -f`
- **Config reload:** `sudo nixos-rebuild switch`
