---
domain: 80
id: "NIXH-80-AMF-001"
title: "AMP FHS Wrapper — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [amp, fhs]
description: "AMP FHS Wrapper module."
path: "root/guides/81-amp-fhs.md"
links:
  adr: ADR-81-amp-fhs.md
  guide: 81-amp-fhs.md
  module: modules/80-gaming/81-amp-fhs.nix
---

# "AMP FHS Wrapper"

**Domain:** 80-gaming
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-80-AMF-001"

---

## Overview

This module provides "amp fhs wrapper" functionality for the NixOS system.
"AMP FHS Wrapper module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."amp-fhs-wrapper".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "amp-fhs-wrapper"

# Check config was applied
nixos-option my.services."amp-fhs-wrapper".enable

# Check logs
journalctl -u "amp-fhs-wrapper" -f --no-pager
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

- **Log location:** `journalctl -u "amp-fhs-wrapper" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
