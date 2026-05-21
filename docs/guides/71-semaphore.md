---
domain: 70
id: "NIXH-70-SEM-001"
title: "Semaphore Ansible — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [semaphore, ansible]
description: "Semaphore Ansible module."
path: "root/guides/71-semaphore.md"
links:
  adr: ADR-71-semaphore.md
  guide: 71-semaphore.md
  module: modules/70-forge/71-semaphore.nix
---

# "Semaphore Ansible"

**Domain:** 70-forge
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-70-SEM-001"

---

## Overview

This module provides "semaphore ansible" functionality for the NixOS system.
"Semaphore Ansible module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."semaphore-ansible".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "semaphore-ansible"

# Check config was applied
nixos-option my.services."semaphore-ansible".enable

# Check logs
journalctl -u "semaphore-ansible" -f --no-pager
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

- **Log location:** `journalctl -u "semaphore-ansible" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
