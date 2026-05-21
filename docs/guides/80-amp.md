---
domain: 80
id: "NIXH-80-AMP-001"
title: "AMP Gaming — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [amp, gaming]
description: "AMP Gaming module."
path: "root/guides/80-amp.md"
links:
  adr: ADR-80-amp.md
  guide: 80-amp.md
  module: modules/80-gaming/80-amp.nix
---

# "AMP Gaming"

**Domain:** 80-gaming
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-80-AMP-001"

---

## Overview

This module provides "amp gaming" functionality for the NixOS system.
"AMP Gaming module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."amp-gaming".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "amp-gaming"

# Check config was applied
nixos-option my.services."amp-gaming".enable

# Check logs
journalctl -u "amp-gaming" -f --no-pager
```

## Known Failure Modes

| Symptom | Cause | Fix |
|---|---|---|
| Service not starting | FHS sandbox not built | Run nixos-rebuild switch to build FHS env |
| Instances not accessible | Port not routed | Configure Caddy vhost for web UI |
| FHS build fails | Missing dependency | Check all targetPkgs are available |

## Dependencies

- **Requires:** `00-principles.nix`, `01-configs-registry.nix` (and others per NIXMETA `requires`)
- **Required by:** Higher-domain modules that consume this service

## Maintenance

- **Log location:** `journalctl -u "amp-gaming" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
