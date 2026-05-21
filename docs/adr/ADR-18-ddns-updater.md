---
domain: 10
id: "NIXH-10-NET-009"
title: "DDNS Updater"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,ddns]
description: "Dynamic DNS updater."
path: "docs/adr/ADR-18-ddns-updater.md"
links:
  module: "modules/10-network/18-ddns-updater.nix"
---

# ADR: DDNS Updater

## Decision
Lightweight DDNS updater service.


---

## KB Nuggets

### DDNS für Dynamic IP
Automatische DNS-Updates bei wechselnder Heim-IP. Cloudflare API Token mit minimalen Permissions.
