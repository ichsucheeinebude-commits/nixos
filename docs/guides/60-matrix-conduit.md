---
domain: 60
id: "NIXH-60-MTX-001"
title: "Matrix Conduit — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [matrix, chat]
description: "Operational guide for matrix conduit."
path: "guides/60-matrix-conduit.md"
links:
  adr: docs/adr/ADR-60-matrix-conduit.md
  guide: docs/guides/60-matrix-conduit.md
  module: modules/60-apps/65-matrix-conduit.nix
---

# matrix-conduit — Matrix Conduit

**Domain:** 60  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides matrix conduit.

## Configuration

```nix
my.services.matrix_conduit.enable = true;
```

## Verification

```bash
systemctl status matrix-conduit
nixos-option my.services.matrix_conduit.enable
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

- **Logs:** `journalctl -u matrix-conduit -f`
- **Reload:** `sudo nixos-rebuild switch`
