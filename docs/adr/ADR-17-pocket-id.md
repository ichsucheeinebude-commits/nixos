---
domain: 10
id: "NIXH-10-NET-008"
title: "Pocket-ID"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,oidc]
description: "Pocket-ID OIDC provider."
path: "docs/adr/ADR-17-pocket-id.md"
links:
  module: "modules/10-network/17-pocket-id.nix"
---

# ADR: Pocket-ID

## Decision
Self-hosted SSO via Pocket-ID.


---

## KB Nuggets

### Lightweight Identity: PocketID > Authentik
PocketID ist schlanker, OIDC-nativ, und perfekt für Homelab-Größen. Authentik ist Overkill für < 20 Users.
### Hybrid Identity Model
PocketID (OIDC) für Familie, mTLS für Admin-Dienste. Passkey-Only als langfristiges Ziel.
