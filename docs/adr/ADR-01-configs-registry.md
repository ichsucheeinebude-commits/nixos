---
domain: 00
id: "NIXH-01-REG-001"
title: "SSoT Configs Registry — Architecture Decision"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [config, ssot, identity, paths]
description: "Single Source of Truth for identity, network, paths, and port assignments."
path: "root/adr/ADR-01-configs-registry.md"
links:
  adr: ADR-01-configs-registry.md
  guide: 01-configs-registry.md
  module: modules/00-core/01-configs-registry.nix
---

# NIXH-01-REG-001 — SSoT Configs Registry

**Domain:** 00-core
**Status:** Draft
**Complexity:** 1/5
**ID:** NIXH-01-REG-001

---

## Context

Single Source of Truth for identity, network, paths, and port assignments. This module is in domain 00-core because it provides foundational configuration
that all other modules depend on. It must be evaluated before any domain-specific modules.

## Decision Drivers

1. **Fail-fast:** Configuration errors must be caught at eval time, not runtime
2. **Reproducibility:** No imperative state mutations anywhere in the system
3. **Single Source of Truth:** All identity, network, and path config in one registry
4. **Native NixOS:** Pure NixOS modules, no container abstractions

## Considered Options

### Option A: Native NixOS Module (Chosen)
- **Description:** Implement as a native NixOS module with declarative options
- **Pros:** Integrates with NixOS eval order, testable, version-controlled
- **Cons:** Requires NixOS expertise to modify

### Option B: External configuration management
- **Description:** Use Ansible, Puppet, or similar for initial setup
- **Pros:** Familiar tooling, easier for non-NixOS admins
- **Cons:** Breaks declarative contract, not reproducible, requires external tooling

## Decision

We adopt **Option A** (native NixOS module) because it aligns with the core design principle
of declarative, reproducible infrastructure. The module is evaluated early in the NixOS
eval order, ensuring all subsequent modules can depend on its configuration.

## Consequences

### Positive
- Configuration is fully declarative and version-controlled
- Eval-time assertions catch errors before system mutation
- SSoT pattern prevents configuration drift

### Negative
- Requires understanding of NixOS evaluation order
- Adding new config options requires module schema updates

### Risks
- Over-complicating the registry can make it hard to understand; mitigated by keeping it focused on identity/network/paths/ports

---

> ⚠️ **IMPLEMENTATION NOISE BLOCKED**
> This ADR captures architectural decisions only. Implementation details
> (code snippets, specific values, package versions) belong in the
> corresponding Guide and Module.
