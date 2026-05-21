# ADR-93: Security Assertions

**Status:** Accepted  
**Date:** 2026-05-21  
**Domain:** 90-policy  
**Module:** `93-security-assertions.nix`

## Context

In NixOS, modules can overwrite each other and critical security settings may be silently disabled. Assertions provide a fail-safe mechanism: if a critical assumption is not met, evaluation aborts — no deployment with weak security.

## Decision

Implement **Security Assertions Pattern**:

1. **Helper function `must`** — Short syntax for assertion + message.
2. **Bastelmodus bypass** — In development mode, assertions are skipped.
3. **Critical checks:**
   - SEC-NET-001: Firewall must be enabled.
   - SEC-NET-002: NFTables must be enabled.
   - SEC-SSH-002: Root login via SSH must be forbidden.

## Consequences

### Positive
- Prevents accidental security degradation
- Clear error messages with unique IDs for audit
- Development mode allows flexibility

### Negative
- May block deployment if legitimate override needed
- Requires understanding of assertion system

## SRE Standards

- Assertions are NixOS-native (`config.assertions`)
- Bastelmodus is a conscious bypass, not a security hole
- Every check has a unique ID for audit purposes
