---
domain: 00
id: "NIXH-00-COR-033"
title: "Symbiosis — Hardware Abstraction"
type: adr
status: accepted
complexity: 2
reviewed: 2026-05-21
tags:
  - core
  - hardware
  - microcode
  - discovery
description: "Hardware abstraction layer with auto-discovery, microcode management, and RAM warnings."
provides:
  - my.core.symbiosis
requires:
  - my.core.hardware
links:
  adr: ADR-11-symbiosis.md
  guide: 11-symbiosis.md
  module: modules/00-core/11-symbiosis.nix
---

# ADR-11: Symbiosis — Hardware Abstraction

> Auto-detect CPU vendor for microcode updates, warn on low RAM, and provide hardware discovery CLI.

---

## Context

CPU microcode updates are critical for security (Spectre, Meltdown). The system must auto-detect Intel vs. AMD and load the correct microcode. Low-RAM systems need early warnings.

---

## Decision

**Hardware-Discovery Pattern:**

1. **Microcode Auto-Select** — Based on `cpuType` (intel/amd).
2. **RAM Warning** — System warning if < 4GB detected.
3. **HW Profile Age Check** — Alert if hardware config is > 30 days old.
4. **`nixhome-detect-hw`** — CLI tool for hardware detection.

---

## Consequences

**Positiv:** No manual CPU vendor config needed, early warnings for underpowered hardware.
**Negativ:** Requires `my.core.hardware` to be populated before evaluation.
