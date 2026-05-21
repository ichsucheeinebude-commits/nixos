---
domain: 20
id: "NIXH-20-SSC-001"
title: "Secrets Schema — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [sops, schema]
description: "Secrets Schema module."
path: "root/guides/23-secrets-schema.md"
links:
  adr: ADR-23-secrets-schema.md
  guide: 23-secrets-schema.md
  module: modules/20-security/23-secrets-schema.nix
---

# "Secrets Schema"

**Domain:** 20-security
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-20-SSC-001"

---

## Overview

This module provides "secrets schema" functionality for the NixOS system.
"Secrets Schema module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."secrets-schema".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "secrets-schema"

# Check config was applied
nixos-option my.services."secrets-schema".enable

# Check logs
journalctl -u "secrets-schema" -f --no-pager
```

## Known Failure Modes

| Symptom | Cause | Fix |
|---|---|---|
| Service not starting | Configuration error | Check journalctl for error messages |
| Port conflict | Another service using same port | Change port in my.ports |
| Permission denied | User/group not created | Verify user exists with correct UID/GID |

## Dependencies

- **Requires:** `00-principles.nix`, `01-configs-registry.nix` (and others per NIXMETA `requires`)
- **Required by:** Higher-domain modules that consume this service

## Maintenance

- **Log location:** `journalctl -u "secrets-schema" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
