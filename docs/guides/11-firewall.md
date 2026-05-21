---
domain: 10
id: "NIXH-10-NET-002"
title: "Firewall Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,firewall]
description: "Configure firewall."
path: "docs/guides/GUIDE-11-firewall.md"
links:
  module: "modules/10-network/11-firewall.nix"
---

# Guide: Firewall Guide

Add ports to my.network.firewall.allowedTCPPorts.


---

## KB Nuggets

### Nftables Mastery
Zonen-basierte Regeln: LAN (voll), Tailscale (services), WAN (nur 80/443). Default-deny mit expliziten Allow-Regeln.
