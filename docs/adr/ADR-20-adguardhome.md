# ADR-20: AdGuard Home DNS Filtering

**Status:** Accepted  
**Date:** 2026-05-21  
**Domain:** 10-network  
**Module:** `20-adguardhome.nix`

## Context

DNS filtering is the first line of defense against trackers, malware, and unwanted ads. AdGuard Home provides declarative configuration with blocklists, DNSSEC, and optimized caching.

## Decision

Implement **AdGuard Home Pattern**:

1. **DoH Upstream** — Encrypted DNS resolution over HTTPS.
2. **DNSSEC** — Validation of DNS responses.
3. **Optimized Cache** — 32MB, TTL 5min-24h, optimistic caching.
4. **Expert Blocklists** — AdGuard Base, Tracking, StevenBlack, OISD Small.
5. **DNS Rewrites** — Local domain resolution without external DNS server.
6. **Strict Sandboxing** — CapabilityBoundingSet, ProtectSystem, NoNewPrivileges.

## Consequences

### Positive
- Network-wide ad and tracker blocking
- DNSSEC validation prevents DNS spoofing
- Optimized caching reduces upstream DNS queries

### Negative
- Additional service to maintain
- Blocklist updates consume bandwidth
- May break some legitimate services (false positives)

## SRE Standards

- Firewall stays closed (openFirewall = false)
- Bind to LAN + Tailscale IPs, not 0.0.0.0
- Client IP anonymization enabled
