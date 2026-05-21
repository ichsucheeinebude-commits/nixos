---
domain: 10
id: "NIXH-10-SRE-001"
title: "SSH Rescue Access — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [ssh, rescue]
description: "Operational guide for ssh rescue access."
path: "guides/10-ssh-rescue.md"
links:
  adr: docs/adr/ADR-10-ssh-rescue.md
  guide: docs/guides/10-ssh-rescue.md
  module: modules/10-network/13-ssh-rescue.nix
---

# ssh-rescue — SSH Rescue Access

**Domain:** 10  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides ssh rescue access.

## Configuration

```nix
my.services.ssh_rescue.enable = true;
```

## Verification

```bash
systemctl status ssh-rescue
nixos-option my.services.ssh_rescue.enable
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

- **Logs:** `journalctl -u ssh-rescue -f`
- **Reload:** `sudo nixos-rebuild switch`
