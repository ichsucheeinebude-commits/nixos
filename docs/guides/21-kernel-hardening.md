---
domain: 20
id: "NIXH-20-KHD-001"
title: "Kernel Hardening — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [kernel, hardening]
description: "Kernel Hardening module."
path: "root/guides/21-kernel-hardening.md"
links:
  adr: ADR-21-kernel-hardening.md
  guide: 21-kernel-hardening.md
  module: modules/20-security/21-kernel-hardening.nix
---

# "Kernel Hardening"

**Domain:** 20-security
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-20-KHD-001"

---

## Overview

This module provides "kernel hardening" functionality for the NixOS system.
"Kernel Hardening module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."kernel-hardening".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "kernel-hardening"

# Check config was applied
nixos-option my.services."kernel-hardening".enable

# Check logs
journalctl -u "kernel-hardening" -f --no-pager
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

- **Log location:** `journalctl -u "kernel-hardening" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
