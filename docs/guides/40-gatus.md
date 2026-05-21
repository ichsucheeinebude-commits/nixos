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

---
## Dashboard Comparison Analysis (from KB)

# 📊 [SERVICES]: Dashboard Vergleich (Glance vs. Homepage vs. Homer) (v4.2)

## 👤 1. USER LAYER (KISS)
"Oma-Logik": Wir brauchen eine Startseite für deinen Server. Wir haben drei Optionen: Ein "Profi-Cockpit" für dich (Glance/Homepage) und eine ganz einfache Seite mit nur drei Knöpfen für die Familie (Homer).
- **Problem:** Ein Dashboard mit 50 Diensten verwirrt die Familie.
- **Lösung:** Wir trennen die Dashboards. Du bekommst alle technischen Infos, die Familie nur die Links zu den Filmen und Hörbüchern.
- **Vorteil:** Übersichtlichkeit für alle.

---

## ⚙️ 2. TECHNICAL LAYER (AVIATION-GRADE)
Vergleich der Dashboard-Technologien in NixOS.

### 🏠 2.1 Homepage (Der Allrounder)
- **NixOS Integration:** Exzellent. Vollständige Konfiguration in Nix-Syntax möglich (`services.homepage-dashboard`).
- **Features:** Widgets für Container-Status, API-Integrationen (Sonarr/Radarr), schönes UI.
- **Nachteil:** Kein natives Multi-User. Lösung: Zwei separate Instanzen.

### ⚡ 2.2 Glance (Das Profi-Cockpit)
- **Technik:** Geschrieben in Go, extrem schnell (< 20MB RAM), statische Binary.
- **Features:** Starker Fokus auf Feeds (RSS, Reddit, YouTube) + Service-Links.
- **NixOS:** Modul vorhanden, aber Konfiguration aktuell noch primär via YAML.

### 🧊 2.3 Homer (Das Familien-Dashboard)
- **Technik:** Komplett statisch, extrem leichtgewichtig.
- **Features:** Reine Link-Liste, schlichtes Design.
- **Einsatz:** Ideal als "Einstiegsdroge" für die Familie hinter Cloudflare Access.

---

## 🧠 3. REASONING LAYER (HISTORY)
Architektonische Herleitung:
- **Trennung der Belange:** Admins brauchen Monitoring-Daten, User brauchen Funktionalität. 
- **Wartbarkeit:** Da alle drei Tools NixOS-Module haben, erfolgt die Konfiguration deklarativ im Flake. Keine manuelle Pflege von Docker-Volumes für die Dashboards nötig.
- **Sicherheit:** Dashboards werden nicht öffentlich exponiert, sondern sind ausschließlich über Cloudflare Access + PocketID erreichbar.

> [SOURCE-ENRICHMENT]: Extracted from `Cl

---
## Homepage Dashboard MASTER-CONFIG (from KB)

---
title: 📚 Homepage MASTER-VARIABLE-LIST (v1.0)
category: architecture/reference
status: [ACTIVE-SSoT]
sources: [https://github.com/gethomepage/homepage]
---

# 📚 Homepage Dashboard: Konfigurations-Referenz

HOMEPAGE_ALLOWED_HOSTS
HOMEPAGE_BUILDTIME
HOMEPAGE_CONFIG_DIR
HOMEPAGE_FILE_
HOMEPAGE_FILE_SECRET
HOMEPAGE_FILE_XXX
HOMEPAGE_PROXY_DISABLE_IPV6
HOMEPAGE_VAR_
HOMEPAGE_VAR_FOO
HOMEPAGE_VAR_TITLE
HOMEPAGE_VAR_XXX

## 🚀 SRE-Anwendung
In NixOS nutzen wir \`services.homepage-dashboard\`.
