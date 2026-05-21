---
domain: 00
id: "NIXH-00-COR-007"
title: "Config Merger Guide"
type: guide
status: draft
complexity: 2
reviewed: 2026-05-21
tags:
  - config
  - merger
  - json
  - runtime
description: "Dynamic bridge between NixOS declarations and user-managed JSON overrides."
provides:
  - my.core.configMerger
requires:
  - my.core.identity
links:
  adr: ADR-13-config-merger.md
  guide: 13-config-merger.md
  module: modules/00-core/13-config-merger.nix
---

# 13-config-merger: Config Merger

> Merge NixOS defaults with user JSON overrides at runtime.

---

## Prerequisites

- [ ] Domain `00-core` is deployed and healthy
- [ ] `my.core.identity` is configured (domain, host)

---

## How It Works

1. Nix defaults are written as JSON from `my.core.identity` settings.
2. User overrides in `/var/lib/nixhome/user-config.json` are deep-merged via `jq`.
3. Result is placed in `/run/nixhome/config.json` (tmpfs, not persistent).
4. `nixhome-apply` script merges and reloads dependent services.

---

## Operational Procedures

### Enable

```nix
my.core.configMerger.enable = true;
```

### Add User Overrides

Edit `/var/lib/nixhome/user-config.json`:
```json
{
  "custom_key": "custom_value"
}
```

### Apply Changes

```bash
nixhome-apply
```

---

## Verification

```bash
cat /run/nixhome/config.json
```
