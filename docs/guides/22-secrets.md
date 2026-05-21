---
domain: 20
id: "NIXH-20-SEC-001"
title: "SOPS Secrets Management — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [sops, secrets]
description: "SOPS Secrets Management module."
path: "root/guides/22-secrets.md"
links:
  adr: ADR-22-secrets.md
  guide: 22-secrets.md
  module: modules/20-security/22-secrets.nix
---

# "SOPS Secrets Management"

**Domain:** 20-security
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-20-SEC-001"

---

## Overview

This module provides "sops secrets management" functionality for the NixOS system.
"SOPS Secrets Management module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."sops-secrets-management".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "sops-secrets-management"

# Check config was applied
nixos-option my.services."sops-secrets-management".enable

# Check logs
journalctl -u "sops-secrets-management" -f --no-pager
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

- **Log location:** `journalctl -u "sops-secrets-management" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
