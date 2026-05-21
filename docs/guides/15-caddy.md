---
domain: 10
id: "NIXH-10-NET-006"
title: "Caddy Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,caddy]
description: "Configure Caddy."
path: "docs/guides/GUIDE-15-caddy.md"
links:
  module: "modules/10-network/15-caddy.nix"
---

# Guide: Caddy Guide

Set email for ACME registration.


---

## KB Nuggets

### Caddyfile Mastery
```caddyfile
:443 {
  reverse_proxy /api/* localhost:8080
  reverse_proxy /* localhost:3000
  tls internal {
    on_demand
  }
}
```
Operations, API, Logging → guides/caddy/
### Orange vs Gray Cloud
**Orange (Proxied):** Vaultwarden, Paperless — schützt Heim-IP.
**Gray (DNS-only):** Jellyfin — Cloudflare Free hat Streaming-Limits.

### ---

title: 🌐 Caddy Gateway Mastery (The Pro-Layer)
category: architecture/gateway
status: [ACTIVE-SSoT]
capabilities: [json-api-control, graceful-reloads, on-demand-tls, metrics-exporter]
sources: [Caddy Official Docs, Caddy GitHub, NixOS Module Audit]
---

# 🌐 Caddy: Das Gehirn deines Netzwerks

In mynixos verschmelzen wir die deklarative Power von Nix mit der dynamischen Agilität der Caddy-API.

### ⚡ 1. Zero-Downtime Updates (Graceful Reload)

Wir nutzen die nativen Caddy-Reload-Signale, um deine aktiven Streams (Jellyfin/Navidrome) bei Konfigurations-Updates zu schützen.
- **SRE-Vorteil:** Die Konfiguration wird atomar im Speicher getauscht. Kein Abbruch von HTTP-Sessions. ✅

### 💎 2. Die Admin-API (Monitoring & Control)

Caddy bietet eine mächtige REST-API auf Port 2019. Wir nutzen dies für Echtzeit-Einsichten.
- **Pattern:** Integration in Prometheus/Grafana für Layer 80 Monitoring.
- **SRE-Kontrolle:** Wir können Routen im Notfall über die API deaktivieren, ohne einen kompletten System-Rebuild abzuwarten.

### 🛡️ 3. On-Demand TLS (Dynamic SSL)

Caddy kann Zertifikate beim ersten Zugriff automatisch generieren.
- **Dienst:** \`on_demand_tls { ... }\` in den Global Options.
- **Vorteil:** Maximale Flexibilität für temporäre Test-Domains innerhalb deines m7c5.de Netzwerks. ✅

### ---

title: 🛡️ Caddy Operations Master-Config (Layer 20-server)
category: architecture/ingress
status: [ACTIVE-SSoT]
capabilities: [ingress-automation, zero-downtime, api-control, caddyfile-mastery]
sources: [https://caddyserver.com/docs/]
---

# 🛡️ Caddy Operations: Der mynixos Standard

Caddy ist das Herzstück deines Ingress-Layers. Wir nutzen die offizielle Philosophie für maximale Zuverlässigkeit.

### 🛠️ Der SRE-Workflow (CLI)

Wir nutzen diese Befehle zur Wartung:
1.  **Validierung:** \`caddy validate --config /etc/caddy/Caddyfile\` (Prüft Syntaxfehler).
2.  **Formatierung:** \`caddy fmt --overwrite /etc/caddy/Caddyfile\` (Garantierte Purity).
3.  **Trust:** \`caddy trust\` (Ermöglicht vertrauenswürdige interne HTTPS-Verbindungen).

### 📡 API-Interaktion

Für Live-Status-Abfragen nutzen wir den internen API-Endpunkt:
- **Status:** \`curl localhost:2019/config/\`
- **Reload:** \`curl -X POST \"http://localhost:2019/load\" -H \"Content-Type: application/json\" -d @config.json\`

### 🧩 Caddyfile Architektur (Dendritic Style)

Wir nutzen **Snippets**, um Redundanz zu vermeiden:
\`\`\`caddy
(pocket_id_auth) {
    forward_auth localhost:8080 {
        uri /api/oidc/auth
    }
}

# Anwendung im Dendriten
jellyfin.m7c5.de {
    import pocket_id_auth
    reverse_proxy localhost:8096
}
\`\`\`
