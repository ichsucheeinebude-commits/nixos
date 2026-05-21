---
domain: 70
id: "NIXH-70-CKP-001"
title: "Cockpit Web Admin — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [cockpit, admin]
description: "Cockpit Web Admin module."
path: "root/guides/72-cockpit.md"
links:
  adr: ADR-72-cockpit.md
  guide: 72-cockpit.md
  module: modules/70-forge/72-cockpit.nix
---

# "Cockpit Web Admin"

**Domain:** 70-forge
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-70-CKP-001"

---

## Overview

This module provides "cockpit web admin" functionality for the NixOS system.
"Cockpit Web Admin module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."cockpit-web-admin".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "cockpit-web-admin"

# Check config was applied
nixos-option my.services."cockpit-web-admin".enable

# Check logs
journalctl -u "cockpit-web-admin" -f --no-pager
```

## Known Failure Modes

| Symptom | Cause | Fix |
|---|---|---|
| Service not accessible | DNS misconfiguration | Check DNS record and port mapping |
| Database locked | Permission issue | Check file permissions and single instance |
| SSO broken | Pocket-ID not responding | Verify Pocket-ID service status |

## Dependencies

- **Requires:** `00-principles.nix`, `01-configs-registry.nix` (and others per NIXMETA `requires`)
- **Required by:** Higher-domain modules that consume this service

## Maintenance

- **Log location:** `journalctl -u "cockpit-web-admin" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
