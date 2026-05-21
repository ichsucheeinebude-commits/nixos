---
domain: 90
id: "NIXH-90-DOM-001"
title: "Domain 90 — Policy Architecture"
type: adr
status: accepted
complexity: 3
reviewed: 2026-05-21
tags:
  - domain
  - 90
  - policy
  - architecture
description: "Architectural decisions for the 90-policy domain."
provides:
  - my.policy.*
requires:
  - my.core.*
links:
  adr: docs/adr/ADR-90-policy.md
  guide: docs/guides/90-policy.md
---

# ADR-90: Domain Policy Architecture

> Governance layer: forbidden technology assertions, architecture guard rails, deferred operations, security assertions, and binary-only build policy — enforced at NixOS evaluation time.

---

## Context

Domain 90 is the governance layer that enforces architectural decisions at build time. It contains NixOS assertions that prevent architectural drift, forbidden technology checks, security assertions, and build policies. If any assertion fails, evaluation aborts — no deployment with policy violations. The bastelmodus (development mode) provides a conscious bypass for experimentation.

---

## Decisions

### 90-90: Forbidden Technology
**Decision:** Docker, Tailscale (as exit-node), cron, iptables, Lanzaboote, and SFTPGo are forbidden. Build-time assertions prevent their use. Native systemd services are mandatory. Supply-chain security via declarative builds.
**Rationale:** Docker contradicts NixOS principles (declarative, reproducible). iptables is deprecated (NFTables is the standard). cron is replaced by systemd timers. Lanzaboote is deferred (not yet stable). Native services are auditable and version-controlled.
**Alternatives considered:** Allow Docker for specific cases (rejected — breaks NixOS purity), iptables as fallback (rejected — NFTables-only is cleaner).

### 90-91: Architecture Rules
**Decision:** Build-time assertions prevent architectural drift. Feature-oriented (dendritic) architecture. Auto-import via import-tree. Deferred modules for conflict minimization. No specialArgs. Evolution from monolith to dendritic is reversible.
**Rationale:** Assertions catch architectural violations before deployment. Feature-oriented architecture scales better than class-oriented. Deferred modules prevent attribute merge conflicts.
**Alternatives considered:** Manual architecture review (rejected — human error).

### 90-92: Deferred Storage Operations
**Decision:** Deletion operations for storage respect HDD sleep cycles. Native NixOS module with systemd service integration. Declarative and reproducible.
**Rationale:** HDDs in Tier C (cold storage) spin down to save power. Immediate deletion would wake them unnecessarily. Deferred operations batch deletions to minimize disk wake-ups.
**Alternatives considered:** Immediate deletion (rejected — HDD wake-ups waste power and cause wear).

### 90-93: Security Assertions
**Decision:** `must` helper function for assertion + message syntax. Bastelmodus bypass for development mode. Critical checks: SEC-NET-001 (firewall enabled), SEC-NET-002 (NFTables enabled), SEC-SSH-002 (root SSH login forbidden). Unique IDs for every check (audit trail).
**Rationale:** Prevents accidental security degradation. Clear error messages with unique IDs enable audit. Bastelmodus allows flexibility during development without compromising production security.
**Alternatives considered:** Runtime security checks (rejected — too late, deployment already happened).

### 90-94: Binary-Only Build Policy
**Decision:** `max-jobs = 0` — no local builds allowed. Assertion ensures max-jobs is not accidentally overridden. Cachix or nix-community as fallback substituters.
**Rationale:** On resource-constrained servers (16GB RAM, i3 CPU), local compilation cripples the system. Binary-only ensures fast, predictable deployments. Assertion prevents accidental override.
**Alternatives considered:** Allow local builds (rejected — resource exhaustion risk), hybrid approach (rejected — unpredictable build times).

---

## Consequences

### Positive
- Architectural drift is impossible — assertions catch violations at build time
- Security degradation is prevented by fail-fast assertions
- Binary-only policy ensures fast, resource-efficient deployments
- Bastelmodus enables safe experimentation
- Forbidden technology list keeps the codebase clean and NixOS-native

### Negative
- Assertions may block legitimate overrides (requires `lib.mkForce`)
- Binary-only policy fails when no cache binary exists (requires external build infrastructure)
- Policy enforcement requires understanding of the assertion system
- Deferred operations add complexity to storage management

---

## Module Inventory

| Module | Purpose |
|--------|---------|
| 90-forbidden-tech.nix | Forbidden technology assertions (Docker, iptables, etc.) |
| 91-architecture-rules.nix | Architecture guard rails, dendritic pattern enforcement |
| 92-deferred-ops.nix | HDD-sleep-respecting deferred deletion operations |
| 93-security-assertions.nix | Security fail-fast assertions with unique IDs |
| 94-binary-only.nix | max-jobs=0, binary-only build enforcement |

---

## Cross-Domain Dependencies

- Depends on: Domain 00 (core)
- Used by: All domains (policy applies globally)
