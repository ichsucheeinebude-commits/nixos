---
domain: 90
id: "NIXH-90-FBT-001"
title: "Forbidden Tech Policy — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [policy, forbidden]
description: "Operational guide for forbidden tech policy."
path: "guides/90-forbidden-tech.md"
links:
  adr: docs/adr/ADR-90-forbidden-tech.md
  guide: docs/guides/90-forbidden-tech.md
  module: modules/90-policy/90-forbidden-tech.nix
---

# forbidden-tech — Forbidden Tech Policy

**Domain:** 90  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides forbidden tech policy.

## Configuration

```nix
my.services.forbidden_tech.enable = true;
```

## Verification

```bash
systemctl status forbidden-tech
nixos-option my.services.forbidden_tech.enable
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

- **Logs:** `journalctl -u forbidden-tech -f`
- **Reload:** `sudo nixos-rebuild switch`
