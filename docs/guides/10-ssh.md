---
domain: 10
id: "NIXH-10-SSH-001"
title: "SSH Hardening — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [ssh, security]
description: "Operational guide for ssh hardening."
path: "guides/10-ssh.md"
links:
  adr: docs/adr/ADR-10-ssh.md
  guide: docs/guides/10-ssh.md
  module: modules/10-network/12-ssh.nix
---

# ssh — SSH Hardening

**Domain:** 10  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides ssh hardening.

## Configuration

```nix
my.services.ssh.enable = true;
```

## Verification

```bash
systemctl status ssh
nixos-option my.services.ssh.enable
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

- **Logs:** `journalctl -u ssh -f`
- **Reload:** `sudo nixos-rebuild switch`
