---
domain: 10
id: "NIXH-10-NET-005"
title: "Blocky Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,dns]
description: "Configure Blocky."
path: "docs/guides/GUIDE-14-blocky.md"
links:
  module: "modules/10-network/14-blocky.nix"
---

# Guide: Blocky Guide

Set upstreamDns and blockingLists.


---

## KB Nuggets

### Blocky Performance DNS
Go-basierter DNS-Proxy mit Blocklisten, Caching, und Conditional Forwarding. Deutlich leichter als AdGuardHome.

### ---

title: ⚡ Blocky Performance DNS (Layer 20-server)
category: architecture/services
status: [ACTIVE-SSoT]
capabilities: [ultra-fast-dns, doh-dot-support, prometheus-metrics, declarative-filter]
sources: [https://github.com/0xERR0R/blocky, official nixpkgs modules]
---

# ⚡ Blocky: Der hocheffiziente DNS-Proxy

In mynixos ist Blocky die performante Alternative zu AdGuardHome. Er ist ideal für SREs, die maximale Geschwindigkeit und minimale Ressourcenbindung suchen.

### 🏛️ Architektur-Entscheidungen (Efficiency Standard)

1.  **Sprache:** Go (Binary-Mandat erfüllt). ✅
2.  **Stateless:** Keine Datenbank nötig. Alle Statistiken werden via Prometheus exportiert.
3.  **Config-First:** Keine Web-UI. Die gesamte Steuerung erfolgt über die Nix-Datei.

### ⚙️ Deklarative Nix-Konfiguration

Hier ist das Muster für deinen Dendriten (\`modules/20-server/dns-performance.nix\`):

\`\`\`nix
services.blocky = {
  enable = true;
  settings = {
    ports.dns = 53;
    upstream = {
      default = [
        \"https://one.one.one.one/dns-query\"
        \"8.8.8.8\"
      ];
    };
    blocking = {
      blackLists = {
        ads = [ \"https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts\" ];
      };
      clientGroupsBlock = {
        default = [ \"ads\" ];
      };
    };
    prometheus = {
      enable = true;
      path = \"/metrics\";
    };
  };
};
\`\`\`
