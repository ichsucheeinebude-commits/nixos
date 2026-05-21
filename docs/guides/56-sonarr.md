---
domain: 50
id: "NIXH-50-SON-001"
title: "Sonarr TV — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [sonarr, tv]
description: "Sonarr TV module."
path: "root/guides/56-sonarr.md"
links:
  adr: ADR-56-sonarr.md
  guide: 56-sonarr.md
  module: modules/50-media/56-sonarr.nix
---

# "Sonarr TV"

**Domain:** 50-media
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-50-SON-001"

---

## Overview

This module provides "sonarr tv" functionality for the NixOS system.
"Sonarr TV module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."sonarr-tv".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "sonarr-tv"

# Check config was applied
nixos-option my.services."sonarr-tv".enable

# Check logs
journalctl -u "sonarr-tv" -f --no-pager
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

- **Log location:** `journalctl -u "sonarr-tv" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
