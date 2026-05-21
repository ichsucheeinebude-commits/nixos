# ADR-94: Binary-Only Build Policy

**Status:** Accepted  
**Date:** 2026-05-21  
**Domain:** 90-policy  
**Module:** `94-binary-only.nix`

## Context

On resource-constrained servers (e.g., 16GB RAM, weak CPU), local package compilation can cripple the system. The Binary-Only Policy forces Nix to exclusively load pre-built binaries from caches.

## Decision

Implement **Binary-Only Pattern**:

1. **max-jobs = 0** — No local builds allowed.
2. **Assertion** — Ensures max-jobs is not accidentally overridden.
3. **Substituters** — Cachix or nix-community as fallback for binaries.

## Consequences

### Positive
- Zero CPU impact from builds
- Fast deployments (download vs. compile)
- Predictable build artifacts

### Negative
- If no binary in cache, build fails
- May need to wait for upstream cache updates
- Custom packages require external build infrastructure

## SRE Standards

- max-jobs = 0 means: if no binary in cache, build fails
- Assertion gives clear error message on policy violation
- Exceptions only via `lib.mkForce` in host-specific configs
