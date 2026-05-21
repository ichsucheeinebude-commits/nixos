---
domain: 40
id: "NIXH-40-MON-004"
title: "Scrutiny Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [monitoring,scrutiny]
description: "Configure Scrutiny."
path: "docs/guides/GUIDE-43-scrutiny.md"
links:
  module: "modules/40-monitoring/43-scrutiny.nix"
---

# Guide: Scrutiny Guide

Requires drive access permissions.


---

## KB Nuggets

=== Scrutiny Setup
Web-UI + Collector-Daemon. Smart-Scan alle 12h. Alert-Thresholds konfigurierbar.

---
## Scrutiny Monitoring (from KB)

---
title: "Service: Scrutiny (Hard Drive Health Monitoring)"
category: "services"
tags: [monitoring, smart, hdd, health, influxdb, dendritic]
id: "NIXH-80-MON-003"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["80-monitoring/service-scrutiny.nix"]
---

# Service: Scrutiny (HDD Health Dashboard)

## 1. User Layer (KISS)
Scrutiny ist der „Arzt“ für deine Festplatten. Er überwacht ständig den Gesundheitszustand (S.M.A.R.T. Werte) deiner SSDs und HDDs. Falls eine Platte Anzeichen von Schwäche zeigt, warnt dich das System, bevor Daten verloren gehen. Über ein übersichtliches Dashboard siehst du auf einen Blick die Temperatur und den Verschleiß deiner Hardware.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Komponenten
*   **Web-UI:** Erreichbar über .
*   **Datenspeicher:** Nutzt eine integrierte InfluxDB für historische Trends.
*   **Collector:** Ein automatischer täglicher Scan sammelt die Rohdaten aller Laufwerke ein.
*   **smartd:** Das Modul aktiviert zwingend den  Dienst für Echtzeit-Ereignisse.

### SRE Hardening & Security
*   **Proxy-Absicherung:** Das Web-Interface lauscht nur auf 127.0.0.1 und ist via Caddy + Pocket-ID SSO geschützt.
*   **Sandboxing:** Nutzt  und .
*   **Priorität:** .

### Integration (Nix-Snippet)


## 3. Reasoning Layer (History)

### [ADR-052] Scrutiny vs. Bare Smartctl
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Reine Kommandozeilen-Tools werden oft ignoriert.
*   **Entscheidung:** Nutzung von Scrutiny als visuelle Schicht.
*   **Vorteil:** Die Trend-Analyse erkennt Hardware-Drift oft früher als statische Schwellwerte.

---
**Community-Abgleich:** Konform zu nixpkgs/nixos/modules/services/monitoring/scrutiny.nix.

