---
domain: 20
id: "NIXH-20-SEC-001"
title: "SOPS Secrets Management — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [sops, secrets]
description: "Operational guide for sops secrets management."
path: "guides/20-secrets.md"
links:
  adr: docs/adr/ADR-20-secrets.md
  guide: docs/guides/20-secrets.md
  module: modules/20-security/22-secrets.nix
---

# secrets — SOPS Secrets Management

**Domain:** 20  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides sops secrets management.

## Configuration

```nix
my.services.secrets.enable = true;
```

## Verification

```bash
systemctl status secrets
nixos-option my.services.secrets.enable
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

- **Logs:** `journalctl -u secrets -f`
- **Reload:** `sudo nixos-rebuild switch`
