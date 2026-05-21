---
domain: 20
id: "NIXH-20-KHD-001"
title: "Kernel Hardening — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [kernel, hardening]
description: "Operational guide for kernel hardening."
path: "guides/20-kernel-hardening.md"
links:
  adr: docs/adr/ADR-20-kernel-hardening.md
  guide: docs/guides/20-kernel-hardening.md
  module: modules/20-security/21-kernel-hardening.nix
---

# kernel-hardening — Kernel Hardening

**Domain:** 20  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides kernel hardening.

## Configuration

```nix
my.services.kernel_hardening.enable = true;
```

## Verification

```bash
systemctl status kernel-hardening
nixos-option my.services.kernel_hardening.enable
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

- **Logs:** `journalctl -u kernel-hardening -f`
- **Reload:** `sudo nixos-rebuild switch`
