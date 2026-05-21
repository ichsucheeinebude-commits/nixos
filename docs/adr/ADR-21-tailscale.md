# ADR-21: Tailscale Auto-Connect VPN

**Status:** Accepted  
**Date:** 2026-05-21  
**Domain:** 10-network  
**Module:** `21-tailscale.nix`

## Context

Tailscale provides zero-config WireGuard VPN. The problem: after a reboot, `tailscale up` must be run manually with an auth key.

## Decision

Implement **Auto-Connect Pattern**:

1. **One-Shot Auth Service** — Checks status after boot, logs in automatically.
2. **SOPS Integration** — Auth key from encrypted secrets.yaml.
3. **High Priority** — OOMScoreAdjust = -1000 (never killed).
4. **Caddy Cert Permission** — PermitCertUid for ACME certificates.

## Consequences

### Positive
- Zero-touch VPN after reboot
- Encrypted auth key storage via SOPS
- Daemon never killed under memory pressure

### Negative
- Auth key must be rotated periodically
- Auto-connect may fail if network is not ready

## SRE Standards

- Firewall stays closed (openFirewall = false)
- Client mode only (no exit-node, no subnet-router)
- SSH and DNS acceptance enabled
