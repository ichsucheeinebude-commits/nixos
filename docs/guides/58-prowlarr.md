---
domain: 50
id: "NIXH-50-PRO-001"
title: "Prowlarr Indexer — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [prowlarr, indexer]
description: "Prowlarr Indexer module."
path: "root/guides/58-prowlarr.md"
links:
  adr: ADR-58-prowlarr.md
  guide: 58-prowlarr.md
  module: modules/50-media/58-prowlarr.nix
---

# "Prowlarr Indexer"

**Domain:** 50-media
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-50-PRO-001"

---

## Overview

This module provides "prowlarr indexer" functionality for the NixOS system.
"Prowlarr Indexer module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."prowlarr-indexer".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "prowlarr-indexer"

# Check config was applied
nixos-option my.services."prowlarr-indexer".enable

# Check logs
journalctl -u "prowlarr-indexer" -f --no-pager
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

- **Log location:** `journalctl -u "prowlarr-indexer" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
