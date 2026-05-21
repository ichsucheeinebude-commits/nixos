---
domain: 40
id: "NIXH-40-MON-001"
title: "Gatus Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
source: "claude-cloudflare-log-b99bb6b3"
tags: [monitoring,gatus]
description: "Configure Gatus."
path: "docs/guides/GUIDE-40-gatus.md"
links:
  module: "modules/40-monitoring/40-gatus.nix"
---

# Guide: Gatus Guide

Add endpoints to my.monitoring.gatus.endpoints.


---

## KB Nuggets

=== Gatus Master-Config
Endpoints für alle 20+ Services. Interval: 30s. Timeout: 10s. Alert: Ntfy-Webhook.

---
## Gatus MASTER-CONFIG (from KB)

---
title: 📚 Gatus MASTER-CONFIG-REFERENCE (v1.0)
category: architecture/reference
status: [ACTIVE-SSoT]
capabilities: [declarative-monitoring, health-api, matrix-alerting, prometheus-export]
sources: [https://github.com/TwiN/gatus (Source Audit)]
---

# 📚 Gatus: Die hocheffiziente Monitoring-Referenz

Dieses Dokument dient als technischer Schaltplan für die Implementierung von Gatus in mynixos.

## 🏛️ 1. Kern-Schnittstellen (SRE Ingress)
Diese Endpunkte werden via Caddy (Layer 10) exponiert:
- \`/health\`: Selbstüberwachung von Gatus.
- \`/metrics\`: Exportiert Daten im Prometheus-Format (Layer 80).
- \`/api/v1/statuses\`: JSON-Feed für externe Dashboards (z.B. Homepage).

## 🛡️ 2. Alerting-Konfiguration (Aviation-Grade)
Wir binden Matrix als primären Alarm-Kanal ein:
\`\`\`yaml
alerting:
  matrix:
    homeserver: "https://matrix.m7c5.de"
    room-id: "!roomid:m7c5.de"
    access-token: "${MATRIX_TOKEN}" # Via Sops injiziert
\`\`\`

## ⚙️ 3. Deklarative Strategie (NixOS)
In mynixos nutzen wir \`services.gatus.settings\`. Jede neue App (Dendrit) registriert sich automatisch in dieser Liste.
- **Speicherung:** Gatus kann SQLite nutzen, wir bevorzugen aber den **In-Memory-Modus** für maximale Effizienz auf dem Tower (Fuji Q958). ✅

## 🚀 SRE-Anwendung
Gatus ist das "Frühwarnsystem". Es informiert uns via Matrix, bevor ein User merkt, dass Jellyfin oder Nextcloud hängen.
