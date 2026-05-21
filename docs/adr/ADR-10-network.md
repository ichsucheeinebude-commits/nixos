---
domain: 10
id: "NIXH-10-DOM-001"
title: "Domain 10 — Network Architecture"
type: adr
status: accepted
complexity: 3
reviewed: 2026-05-21
tags:
  - domain
  - 10
  - network
  - architecture
description: "Architectural decisions for the 10-network domain."
provides:
  - my.network.*
requires:
  - my.core.*
links:
  adr: docs/adr/ADR-10-network.md
  guide: docs/guides/10-network.md
---

# ADR-10: Domain Network Architecture

> All networking, DNS, reverse proxy, identity, and remote access decisions — from base config to Cloudflare tunnels.

---

## Context

Domain 10 governs all network-facing services: base networking, firewall, SSH access, DNS resolution (Blocky + AdGuardHome), reverse proxy (Caddy), identity provider (Pocket-ID), dynamic DNS, IoT (Zigbee/MQTT), VPN (Tailscale), Cloudflare tunnels, and the service landing page. It implements a 3-layer defense model: Cloudflare WAF (geoblock), CF Access + OIDC (Pocket-ID), and mTLS for admin services.

---

## Decisions

### 10-10: Network Configuration
**Decision:** `systemd-resolved` with DNSSEC `allow-downgrade`. Tailscale SplitDNS for internal services. External domains via Cloudflare Zero Trust.
**Rationale:** systemd-resolved is native NixOS, integrates cleanly. SplitDNS resolves internal services without leaking queries externally.
**Alternatives considered:** dnsmasq (rejected — less integrated), full DNSSEC strict (rejected — breaks some legacy DNS).

### 10-11: NFTables Firewall
**Decision:** NFTables only (no iptables). Configurable public ports. 3-layer defense model enforced at network level.
**Rationale:** NFTables is the modern Linux firewall. Single firewall stack avoids rule conflicts.
**Alternatives considered:** iptables (rejected — deprecated, forbidden by policy), firewalld (rejected — too heavy).

### 10-12: SSH Server
**Decision:** Key-only authentication, configurable port. ProxyJump through Cloudflare Tunnel — no direct SSH port exposed. Post-quantum crypto (`sntrup761x25519-sha512`). Initrd SSH for remote LUKS unlock. Nix binary serving via `nix-ssh-serve`.
**Rationale:** Key-only eliminates brute-force risk. Cloudflare Tunnel avoids port forwarding. PQ crypto future-proofs. Initrd SSH enables headless disk unlock.
**Alternatives considered:** Password auth (rejected — brute-force target), direct port exposure (rejected — attack surface).

### 10-13: SSH Rescue
**Decision:** Separate SSH unit on different port, key-only. 5-minute window after boot, then auto-closes.
**Rationale:** Emergency access when primary SSH is misconfigured. Time-limited window reduces attack surface.
**Alternatives considered:** Permanent rescue SSH (rejected — always-open attack vector).

### 10-14: Blocky DNS
**Decision:** Blocky as local DNS resolver with configurable block lists. Go-based for better performance and native NixOS integration.
**Rationale:** Blocky outperforms AdGuardHome on resource-constrained hardware. Native NixOS module.
**Alternatives considered:** AdGuardHome as primary (rejected — Blocky is lighter), dnsmasq (rejected — no ad-blocking).

### 10-15: Caddy Reverse Proxy
**Decision:** Caddy as reverse proxy with automatic TLS via ACME (DNS-01 challenge via Cloudflare). Forward-auth to Pocket-ID (OIDC). HTTP/3 support. Encrypted Client Hello (ECH). mTLS snippets for admin zones. SSO snippets for app zones. Secret isolation via systemd EnvironmentFile (not in Nix store).
**Rationale:** Caddy provides zero-config TLS, native NixOS module, clean config syntax. HTTP/3 improves mobile performance. ECH protects SNI privacy.
**Alternatives considered:** Traefik (rejected — heavier, less NixOS-native), nginx (rejected — manual TLS management).

### 10-16: DNS Automation
**Decision:** Periodic timer checks Cloudflare DNS for conflicts before new subdomains are created.
**Rationale:** Prevents DNS conflicts when adding services. Automated checks reduce manual errors.
**Alternatives considered:** Manual DNS management (rejected — error-prone).

### 10-17: Pocket-ID
**Decision:** Self-hosted OIDC provider via Pocket-ID. Passkey-only (WebAuthn) — no passwords. Generic OIDC integration with Cloudflare Access. Local user data (no cloud dependency).
**Rationale:** Pocket-ID is lightweight and perfect for homelab scale (< 20 users). Passkeys are phishing-resistant. Cloudflare Access as gatekeeper enables centralized authorization.
**Alternatives considered:** Authentik (rejected — overkill for < 20 users), Keycloak (rejected — too heavy).

### 10-18: DDNS Updater
**Decision:** Lightweight DDNS updater service. Cloudflare API token with minimal permissions.
**Rationale:** Dynamic IP requires automatic DNS updates. Minimal token permissions limit blast radius.
**Alternatives considered:** External DDNS services (rejected — external dependency).

### 10-19: Zigbee Stack
**Decision:** Local MQTT broker (Mosquitto) + Zigbee2MQTT frontend. Native systemd services (no Docker). Zigbee stick directly on host.
**Rationale:** Native systemd avoids Docker overhead. MQTT is the standard IoT message bus.
**Alternatives considered:** Docker containers (rejected — forbidden by policy), Z-Wave (rejected — proprietary).

### 10-20: AdGuard Home
**Decision:** DoH upstream, DNSSEC validation, 32MB cache with optimistic caching. Expert blocklists (AdGuard Base, Tracking, StevenBlack, OISD Small). DNS rewrites for local domains. Strict sandboxing (CapabilityBoundingSet, ProtectSystem, NoNewPrivileges). Bind to LAN + Tailscale only, not 0.0.0.0. Firewall stays closed.
**Rationale:** DNS filtering is first line of defense. DoH upstream encrypts external queries. DNS rewrites eliminate need for separate DNS server.
**Alternatives considered:** Pi-hole (rejected — less NixOS-native), Blocky-only (rejected — AdGuard provides web UI).

### 10-21: Tailscale
**Decision:** Auto-connect pattern — one-shot auth service after boot, SOPS-encrypted auth key. OOMScoreAdjust = -1000 (never killed). Caddy PermitCertUid for ACME. Client mode only (no exit-node, no subnet-router). Firewall stays closed.
**Rationale:** Zero-touch VPN after reboot is essential for headless servers. SOPS keeps auth key encrypted. High OOM priority prevents disconnection under memory pressure.
**Alternatives considered:** Manual `tailscale up` (rejected — requires console access), exit-node mode (rejected — unnecessary exposure).

### 10-22: Cloudflare Tunnel
**Decision:** Outbound-only connection to Cloudflare edge — no open ports. Wildcard ingress (`*.nix.<domain>`) routed to local proxy. SOPS-protected credentials. Origin hardening: HTTP/2, Keep-Alive, TLS verification. Default: 404 for unmapped hosts. PreStart credential check. Strict sandboxing.
**Rationale:** Eliminates port forwarding entirely. DDoS protection via Cloudflare edge. Free TLS certificates.
**Alternatives considered:** Port forwarding (rejected — exposes server directly), self-hosted VPN (rejected — more maintenance).

### 10-23: Landing Zone UI
**Decision:** Static HTML landing page via Caddy listing all services with links. Rescue fallback with SSH access info and recovery instructions. Default virtual host.
**Rationale:** Single entry point for all services. No external dependencies.
**Alternatives considered:** Dynamic dashboard (rejected — unnecessary complexity).

### 10-24: DNS Map
**Decision:** Central attrset maps service names to subdomains. Used by Caddy for virtual hosts, Blocky/AdGuard for DNS. Automatic `networking.hosts` entries for local resolution.
**Rationale:** Single source of truth for all service hostnames. Automatic propagation eliminates manual tracking.
**Alternatives considered:** Per-service hostname config (rejected — scattered, error-prone).

---

## Consequences

### Positive
- No open ports — all external access via Cloudflare Tunnel
- Consistent SSO across all services via Pocket-ID
- Automatic TLS with zero manual certificate management
- Defense-in-depth: WAF → OIDC → mTLS
- Internal DNS resolves without external queries

### Negative
- Heavy dependency on Cloudflare availability
- Pocket-ID is a single point of failure for authentication
- DNS Map changes require NixOS rebuild to propagate
- Config Merger JSON overrides lost on reboot

---

## Module Inventory

| Module | Purpose |
|--------|---------|
| 10-network.nix | Base networking, systemd-resolved, DNS |
| 11-firewall.nix | NFTables firewall, port management |
| 12-ssh.nix | SSH server, key-only, PQ crypto, initrd unlock |
| 13-ssh-rescue.nix | Emergency SSH, time-limited window |
| 14-blocky.nix | DNS resolver with ad-blocking |
| 15-caddy.nix | Reverse proxy, auto-TLS, SSO, mTLS |
| 16-dns-automation.nix | DNS conflict detection timer |
| 17-pocket-id.nix | OIDC provider, passkey authentication |
| 18-ddns-updater.nix | Dynamic DNS for changing IPs |
| 19-zigbee-stack.nix | MQTT broker + Zigbee2MQTT |
| 20-adguardhome.nix | DNS filtering with blocklists |
| 21-tailscale.nix | Auto-connect WireGuard VPN |
| 22-cloudflared-tunnel.nix | Outbound-only Cloudflare tunnel |
| 23-landing-zone-ui.nix | Static landing page |
| 24-dns-map.nix | Central subdomain mapping |

---

## Cross-Domain Dependencies

- Depends on: Domain 00 (core), Domain 20 (security)
- Used by: All service domains (40–80) via Caddy reverse proxy and DNS mapping
