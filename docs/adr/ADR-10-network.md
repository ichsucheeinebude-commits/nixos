---
domain: 10
id: "NIXH-10-NET-001"
title: "Network Configuration"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network]
description: "Base networking config."
path: "docs/adr/ADR-10-network.md"
links:
  module: "modules/10-network/10-network.nix"
---

# ADR: Network Configuration

## Decision
systemd-resolved with DNSSEC allow-downgrade.


---

## KB Nuggets

### DNS Naming Standard
Tailscale SplitDNS für interne Services. Externe Domains über Cloudflare Zero Trust.
