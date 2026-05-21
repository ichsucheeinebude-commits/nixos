---
domain: 50
id: "NIXH-50-MLB-001"
title: "Media Library Base — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [media, library]
description: "Media Library Base module."
path: "root/guides/50-lib-media.md"
links:
  adr: ADR-50-lib-media.md
  guide: 50-lib-media.md
  module: modules/50-media/50-lib-media.nix
---

# "Media Library Base"

**Domain:** 50-media
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-50-MLB-001"

---

## Overview

This module provides "media library base" functionality for the NixOS system.
"Media Library Base module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."media-library-base".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "media-library-base"

# Check config was applied
nixos-option my.services."media-library-base".enable

# Check logs
journalctl -u "media-library-base" -f --no-pager
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

- **Log location:** `journalctl -u "media-library-base" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
