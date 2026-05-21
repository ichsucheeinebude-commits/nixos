---
domain: 90
id: "NIXH-90-FBT-001"
title: "Forbidden Tech Policy — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [policy, forbidden]
description: "Forbidden Tech Policy module."
path: "root/guides/90-forbidden-tech.md"
links:
  adr: ADR-90-forbidden-tech.md
  guide: 90-forbidden-tech.md
  module: modules/90-policy/90-forbidden-tech.nix
---

# "Forbidden Tech Policy"

**Domain:** 90-policy
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-90-FBT-001"

---

## Overview

This module provides "forbidden tech policy" functionality for the NixOS system.
"Forbidden Tech Policy module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."forbidden-tech-policy".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "forbidden-tech-policy"

# Check config was applied
nixos-option my.services."forbidden-tech-policy".enable

# Check logs
journalctl -u "forbidden-tech-policy" -f --no-pager
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

- **Log location:** `journalctl -u "forbidden-tech-policy" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
