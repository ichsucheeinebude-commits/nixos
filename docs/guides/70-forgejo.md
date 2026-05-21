---
domain: 70
id: "NIXH-70-FRG-001"
title: "Forgejo Git — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [forgejo, git]
description: "Forgejo Git module."
path: "root/guides/70-forgejo.md"
links:
  adr: ADR-70-forgejo.md
  guide: 70-forgejo.md
  module: modules/70-forge/70-forgejo.nix
---

# "Forgejo Git"

**Domain:** 70-forge
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-70-FRG-001"

---

## Overview

This module provides "forgejo git" functionality for the NixOS system.
"Forgejo Git module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."forgejo-git".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "forgejo-git"

# Check config was applied
nixos-option my.services."forgejo-git".enable

# Check logs
journalctl -u "forgejo-git" -f --no-pager
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

- **Log location:** `journalctl -u "forgejo-git" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
