---
domain: 90
id: "NIXH-90-ARC-001"
title: "Architecture Rules — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [architecture, rules]
description: "Architecture Rules module."
path: "root/guides/91-architecture-rules.md"
links:
  adr: ADR-91-architecture-rules.md
  guide: 91-architecture-rules.md
  module: modules/90-policy/91-architecture-rules.nix
---

# "Architecture Rules"

**Domain:** 90-policy
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-90-ARC-001"

---

## Overview

This module provides "architecture rules" functionality for the NixOS system.
"Architecture Rules module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."architecture-rules".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "architecture-rules"

# Check config was applied
nixos-option my.services."architecture-rules".enable

# Check logs
journalctl -u "architecture-rules" -f --no-pager
```

## Known Failure Modes

| Symptom | Cause | Fix |
|---|---|---|
| Build fails | Assertion violation | Remove the violating config option |
| Timer not active | Systemd timer not enabled | Check systemctl status of timer |
| False positive | Config exists but disabled | Use lib.mkForce false to explicitly disable |

## Dependencies

- **Requires:** `00-principles.nix`, `01-configs-registry.nix` (and others per NIXMETA `requires`)
- **Required by:** Higher-domain modules that consume this service

## Maintenance

- **Log location:** `journalctl -u "architecture-rules" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
