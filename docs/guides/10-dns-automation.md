---
domain: 10
id: "NIXH-10-DNS-001"
title: "DNS Automation — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [dns, cloudflare]
description: "Operational guide for dns automation."
path: "guides/10-dns-automation.md"
links:
  adr: docs/adr/ADR-10-dns-automation.md
  guide: docs/guides/10-dns-automation.md
  module: modules/10-network/16-dns-automation.nix
---

# dns-automation — DNS Automation

**Domain:** 10  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides dns automation.

## Configuration

```nix
my.services.dns_automation.enable = true;
```

## Verification

```bash
systemctl status dns-automation
nixos-option my.services.dns_automation.enable
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

- **Logs:** `journalctl -u dns-automation -f`
- **Reload:** `sudo nixos-rebuild switch`
