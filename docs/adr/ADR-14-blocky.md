---
domain: 10
id: "NIXH-10-NET-005"
title: "Blocky DNS"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,dns]
description: "Blocky DNS with ad-blocking."
path: "docs/adr/ADR-14-blocky.md"
links:
  module: "modules/10-network/14-blocky.nix"
---

# ADR: Blocky DNS

## Decision
Local DNS resolver with configurable block lists.


---

## KB Nuggets

### Blocky > AdGuardHome
Blocky (Go) bietet bessere Performance und native NixOS-Integration. AdGuardHome bleibt als Alternative.
