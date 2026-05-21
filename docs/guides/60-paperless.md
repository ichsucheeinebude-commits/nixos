---
domain: 60
id: "NIXH-60-PAP-001"
title: "Paperless-ngx — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [paperless, documents]
description: "Operational guide for paperless-ngx."
path: "guides/60-paperless.md"
links:
  adr: docs/adr/ADR-60-paperless.md
  guide: docs/guides/60-paperless.md
  module: modules/60-apps/60-paperless.nix
---

# paperless — Paperless-ngx

**Domain:** 60  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides paperless-ngx.

## Configuration

```nix
my.services.paperless.enable = true;
```

## Verification

```bash
systemctl status paperless
nixos-option my.services.paperless.enable
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

- **Logs:** `journalctl -u paperless -f`
- **Reload:** `sudo nixos-rebuild switch`
