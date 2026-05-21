---
domain: 60
id: "NIXH-60-HAS-001"
title: "Home Assistant — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [home-assistant, iot]
description: "Operational guide for home assistant."
path: "guides/60-home-assistant.md"
links:
  adr: docs/adr/ADR-60-home-assistant.md
  guide: docs/guides/60-home-assistant.md
  module: modules/60-apps/63-home-assistant.nix
---

# home-assistant — Home Assistant

**Domain:** 60  
**Status:** Draft  
**Complexity:** 1/5

---

## Overview

This module provides home assistant.

## Configuration

```nix
my.services.home_assistant.enable = true;
```

## Verification

```bash
systemctl status home-assistant
nixos-option my.services.home_assistant.enable
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

- **Logs:** `journalctl -u home-assistant -f`
- **Reload:** `sudo nixos-rebuild switch`
