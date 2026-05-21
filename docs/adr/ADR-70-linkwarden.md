# ADR-70: Linkwarden Bookmark Manager

**Status:** Accepted  
**Date:** 2026-05-21  
**Domain:** 60-apps  
**Module:** `70-linkwarden.nix`

## Context

Bookmarks should not be lost in the browser. Linkwarden provides collaborative bookmark management with automatic archiving — every saved URL is stored as a snapshot.

## Decision

Implement **Linkwarden Pattern**:

1. **NixOS Service** — services.linkwarden.enable = true.
2. **Caddy Integration** — Reverse proxy with SSO auth.
3. **DynamicUser Sandboxing** — systemd DynamicUser = true, strict security.
4. **SSO Integration** — import sso_auth in Caddy config.

## Consequences

### Positive
- Persistent, searchable bookmark archive
- Collaborative sharing possible
- Strong systemd sandboxing

### Negative
- Requires PostgreSQL backend
- Archiving consumes disk space
- Additional service to maintain

## SRE Standards

- DynamicUser = true (no fixed user created)
- ProtectSystem = strict, ProtectHome = true
- SystemCallFilter = ["@system-service" "~@privileged"]
- OOMScoreAdjust = 300 (can be killed under memory pressure)
