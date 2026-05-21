---
domain: 10
id: "NIXH-10-NET-007"
title: "DNS Automation"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,dns]
description: "DNS conflict detection."
path: "docs/adr/ADR-16-dns-automation.md"
links:
  module: "modules/10-network/16-dns-automation.nix"
---

# ADR: DNS Automation

## Decision
Periodic timer checks Cloudflare.


---

## KB Nuggets

### DNS Automation Guard
Cloudflare DNS Guard prüft auf Konflikte bevor neue Subdomains angelegt werden.
