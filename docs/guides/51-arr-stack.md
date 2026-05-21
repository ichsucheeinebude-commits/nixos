---
domain: 50
id: "NIXH-50-ARR-001"
title: "Arr Stack Common — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [arr, factory]
description: "Arr Stack Common module."
path: "root/guides/51-arr-stack.md"
links:
  adr: ADR-51-arr-stack.md
  guide: 51-arr-stack.md
  module: modules/50-media/51-arr-stack.nix
---

# "Arr Stack Common"

**Domain:** 50-media
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-50-ARR-001"

---

## Overview

This module provides "arr stack common" functionality for the NixOS system.
"Arr Stack Common module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."arr-stack-common".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "arr-stack-common"

# Check config was applied
nixos-option my.services."arr-stack-common".enable

# Check logs
journalctl -u "arr-stack-common" -f --no-pager
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

- **Log location:** `journalctl -u "arr-stack-common" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
