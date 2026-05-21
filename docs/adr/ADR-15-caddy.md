---
domain: 10
id: "NIXH-10-NET-006"
title: "Caddy Reverse Proxy"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,caddy]
description: "Caddy as reverse proxy."
path: "docs/adr/ADR-15-caddy.md"
links:
  module: "modules/10-network/15-caddy.nix"
---

# ADR: Caddy Reverse Proxy

## Decision
Automatic TLS via ACME.


---

## KB Nuggets

### Caddy M1 Abrams — Reverse Proxy Mastery
Auto-TLS, Geoblock, SSO-Snippets. Orange Cloud (proxied) für App-Daten, Gray Cloud (DNS-only) für High-Bandwidth Medien.
