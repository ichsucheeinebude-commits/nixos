---
domain: 40
id: "NIXH-40-NTD-001"
title: "Netdata Metrics — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [netdata, metrics]
description: "Operational guide for netdata metrics."
path: "guides/40-netdata.md"
links:
  adr: docs/adr/ADR-40-netdata.md
  guide: docs/guides/40-netdata.md
  module: modules/40-monitoring/41-netdata.nix
---

# netdata — Netdata Metrics

**Domain:** 40  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides netdata metrics.

## Configuration

```nix
my.services.netdata.enable = true;
```

## Verification

```bash
systemctl status netdata
nixos-option my.services.netdata.enable
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

- **Logs:** `journalctl -u netdata -f`
- **Reload:** `sudo nixos-rebuild switch`
