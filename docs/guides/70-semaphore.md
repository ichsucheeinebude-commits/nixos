---
domain: 70
id: "NIXH-70-SEM-001"
title: "Semaphore Ansible — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [semaphore, ansible]
description: "Operational guide for semaphore ansible."
path: "guides/70-semaphore.md"
links:
  adr: docs/adr/ADR-70-semaphore.md
  guide: docs/guides/70-semaphore.md
  module: modules/70-forge/71-semaphore.nix
---

# semaphore — Semaphore Ansible

**Domain:** 70  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides semaphore ansible.

## Configuration

```nix
my.services.semaphore.enable = true;
```

## Verification

```bash
systemctl status semaphore
nixos-option my.services.semaphore.enable
```

## Known Failure Modes

| Symptom | Cause | Fix |
|---|---|---|
| Service fails to start | Port conflict | Change port |
| Exit code 127 | Binary missing | Run `nix flake update` |

## Dependencies

- **Requires:** See NIXMETA header
- **Required by:** Higher-domain modules

## Maintenance

- **Logs:** `journalctl -u semaphore -f`
- **Reload:** `sudo nixos-rebuild switch`
