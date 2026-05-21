---
domain: 10
id: "NIXH-10-NET-002"
title: "NFTables Firewall"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,firewall]
description: "NFTables firewall."
path: "docs/adr/ADR-11-firewall.md"
links:
  module: "modules/10-network/11-firewall.nix"
---

# ADR: NFTables Firewall

## Decision
NFTables only, configurable public ports.


---

## KB Nuggets

### 3-Schichten Defensiv-Modell
Schicht 1: Cloudflare WAF (Geoblock DACH). Schicht 2: CF Access + OIDC (Pocket-ID). Schicht 3: mTLS für Admin-Dienste.
