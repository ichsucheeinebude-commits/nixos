# ADR-22: Cloudflare Tunnel

**Status:** Accepted  
**Date:** 2026-05-21  
**Domain:** 10-network  
**Module:** `22-cloudflared-tunnel.nix`

## Context

Traditional port forwarding exposes the server directly to the public internet. Cloudflare Tunnels create an outbound connection to the Cloudflare edge — no open ports, no firewall rules.

## Decision

Implement **Cloudflared Tunnel Pattern**:

1. **Outbound-Only** — Only outgoing connection to Cloudflare (no open port).
2. **Wildcard Ingress** — `*.nix.<domain>` routed to local proxy.
3. **Credential File** — Tunnel auth via SOPS-protected credentials.
4. **Origin Hardening** — HTTP/2, Keep-Alive, TLS verification.

## Consequences

### Positive
- No port forwarding needed
- DDoS protection via Cloudflare edge
- Free TLS certificates

### Negative
- Dependency on Cloudflare availability
- Credentials must be managed securely
- Additional latency from Cloudflare proxy

## SRE Standards

- Credentials must exist before service start (preStart check)
- TunnelID must be set (assertion)
- Default: 404 for unmapped hosts
- Strict sandboxing: ProtectSystem, NoNewPrivileges, CapabilityBoundingSet
