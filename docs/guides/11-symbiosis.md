---
domain: 00
id: "NIXH-00-COR-033"
title: "Symbiosis Guide"
type: guide
status: draft
complexity: 2
reviewed: 2026-05-21
tags:
  - core
  - hardware
  - microcode
description: "Hardware auto-discovery, microcode management, and RAM warnings."
provides:
  - my.core.symbiosis
requires:
  - my.core.hardware
links:
  adr: ADR-11-symbiosis.md
  guide: 11-symbiosis.md
  module: modules/00-core/11-symbiosis.nix
---

# 11-symbiosis: Hardware Abstraction

> Auto-detect CPU, load microcode, warn on low RAM.

---

## Prerequisites

- [ ] `my.core.hardware` is populated (cpuType, ramGB)

---

## How It Works

1. Reads `cpuType` from hardware config → enables correct microcode package.
2. Checks `ramGB` → emits warning if < 4GB.
3. Provides `nixhome-detect-hw` CLI for on-demand detection.

---

## Enable

```nix
my.core.symbiosis.enable = true;
```

---

## Verification

```bash
nixhome-detect-hw
journalctl -b | grep -i microcode
```
