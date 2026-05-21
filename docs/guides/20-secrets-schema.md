---
domain: 20
id: "NIXH-20-SSC-001"
title: "Secrets Schema — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [sops, schema]
description: "Operational guide for secrets schema."
path: "guides/20-secrets-schema.md"
links:
  adr: docs/adr/ADR-20-secrets-schema.md
  guide: docs/guides/20-secrets-schema.md
  module: modules/20-security/23-secrets-schema.nix
---

# secrets-schema — Secrets Schema

**Domain:** 20  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides secrets schema.

## Configuration

```nix
my.services.secrets_schema.enable = true;
```

## Verification

```bash
systemctl status secrets-schema
nixos-option my.services.secrets_schema.enable
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

- **Logs:** `journalctl -u secrets-schema -f`
- **Reload:** `sudo nixos-rebuild switch`
