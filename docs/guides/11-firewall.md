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

### ---

title: 🛡️ Nftables Firewall Mastery (Layer 00-core)
category: architecture/core
status: [ACTIVE-SSoT]
capabilities: [atomic-rulesets, build-time-validation, fail2ban-integration, nat-nft]
sources: [nixpkgs/nixos/modules/services/networking/nftables.nix, fail2ban.nix]
---

# 🛡️ Nftables: Die Aviation-Grade Firewall

In mynixos ist nftables das einzige erlaubte Firewall-Backend. Es ersetzt das veraltete iptables vollständig.

### 🏛️ 1. Die SRE-Konfiguration (Layer 00-core)

Wir nutzen die Build-Zeit-Validierung, um uns niemals auszusperren.
- **Dienst:**
\`\`\`nix
networking.nftables = {
  enable = true;
  checkRuleset = true; # Zwingend: Validierung vor Aktivierung
};
\`\`\`

### 🛡️ 2. Fail2ban Integration (Layer 30-services)

Fail2ban wird angewiesen, nativ mit nftables zu kommunizieren.
\`\`\`nix
services.fail2ban = {
  enable = true;
  banaction = "nftables-multiport";
};
\`\`\`
