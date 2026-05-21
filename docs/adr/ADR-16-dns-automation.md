---
domain: 10
id: "NIXH-10-DNS-001"
title: "DNS Automation — Architecture Decision"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [dns, cloudflare]
description: "DNS Automation module."
path: "root/adr/ADR-16-dns-automation.md"
links:
  adr: ADR-16-dns-automation.md
  guide: 16-dns-automation.md
  module: modules/10-network/16-dns-automation.nix
---

# "NIXH-10-DNS-001" — "DNS Automation"

**Domain:** 10-network
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-10-DNS-001"

---

## Context

"DNS Automation module." This module integrates with the SSoT configs registry for identity and network settings,
and follows the domain-driven architecture pattern established in 00-core.

## Decision Drivers

1. **Security:** Must follow hardening-by-default principle
2. **Simplicity:** Single-responsibility — one file, one concern
3. **Declarative:** No imperative state mutations allowed
4. **Traceability:** Must link to ADR, Guide, and Module siblings
5. **Native NixOS:** No container abstractions — pure NixOS module

## Considered Options

### Option A: Native NixOS Module (Chosen)
- **Description:** Implement as a native NixOS module with systemd service integration
- **Pros:** Declarative, testable, follows NixOS best practices, integrates with SSoT config
- **Cons:** Requires custom module options and understanding of NixOS evaluation order

### Option B: Container-based Deployment
- **Description:** Run in a container (Podman or systemd-nspawn)
- **Pros:** Isolation from host, easier dependency management
- **Cons:** Violates native NixOS philosophy; breaks declarative model; additional attack surface

### Option C: Manual imperative setup
- **Description:** Shell scripts and manual configuration files
- **Pros:** Flexible, no Nix knowledge required
- **Cons:** Not reproducible, not auditable, breaks on rebuild, no version control

## Decision

We adopt **Option A** (native NixOS module) because it aligns with the core design principle
of declarative, reproducible infrastructure. The module integrates with systemd, uses
the SSoT configs registry, and follows the established domain architecture.

## Consequences

### Positive
- Clean separation of concerns within the 10-network domain
- Easy to audit and review via NIXMETA metadata
- Follows the 10-domain isomorphy principle
- Build-time assertions prevent misconfiguration

### Negative
- Requires NixOS expertise to modify
- Custom module options need documentation in the corresponding Guide

### Risks
- Module complexity may increase over time — mitigated with regular review cycles
- Dependency on SSoT configs means configs-registry must be evaluated first

---

> ⚠️ **IMPLEMENTATION NOISE BLOCKED**
> This ADR captures architectural decisions only. Implementation details
> (code snippets, specific port numbers, package versions) belong in the
> corresponding Guide and Module. Do not pollute this document with
> operational how-to content.
