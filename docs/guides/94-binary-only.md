---
domain: 90
id: "NIXH-90-POL-004"
title: "Binary-Only Policy Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags:
  - policy
  - nix
  - binary-cache
description: "Forbid local compilation. All packages must come from binary caches."
provides:
  - my.policy.binaryOnly
requires:
  - my.core.nix
links:
  adr: ADR-94-binary-only.md
  guide: 94-binary-only.md
  module: modules/90-policy/94-binary-only.nix
---

# 94-binary-only: Binary-Only Policy

> Forbid local Nix compilation on resource-constrained systems.

---

## Prerequisites

- [ ] Domain `00-core` is deployed and healthy
- [ ] Internet connectivity for binary cache downloads

---

## How It Works

Sets `max-jobs = 0` to prevent local compilation. All packages must come from binary caches.

---

## Operational Procedures

### Enable

```nix
my.policy.binaryOnly.enable = true;
```

### Verify

```bash
nix show-config | grep max-jobs
```
