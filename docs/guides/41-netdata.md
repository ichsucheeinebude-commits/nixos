---
domain: 40
id: "NIXH-40-MON-002"
title: "Netdata Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [monitoring,netdata]
description: "Configure Netdata."
path: "docs/guides/GUIDE-41-netdata.md"
links:
  module: "modules/40-monitoring/41-netdata.nix"
---

# Guide: Netdata Guide

Access via Caddy reverse proxy.


---

## KB Nuggets

=== Netdata Setup
Privacy-Mode: keine Cloud-Verbindung. Local storage nur. Alert-Konfiguration über health.d/.

---
## Monitoring Cockpit (from KB)

---
title: "Service: Cockpit (Aviation-Grade Web Administration)"
category: "services"
tags: [monitoring, admin, system, dendritic]
id: "NIXH-80-MON-001"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["80-monitoring/cockpit.nix"]
---

# Service: Cockpit (System Administration)

## 1. User Layer (KISS)
Cockpit ist deine grafische Schaltzentrale. Anstatt alles über kryptische Befehle im Terminal zu machen, kannst du hier Festplatten verwalten, Systemlogs einsehen oder Updates prüfen – alles bequem im Browser. Es ist wie das Cockpit eines Flugzeugs: Du siehst alle wichtigen Instrumente deines Servers auf einen Blick.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Funktionen
*   **Modus:** Natives NixOS-Modul (`services.cockpit`).
*   **Web-Proxy Integration:** Konfiguriert für den Betrieb hinter Caddy (`AllowUnencrypted = true`).
*   **Sicherheit:** Sitzungen werden nach 15 Minuten Inaktivität automatisch beendet (`IdleTimeout = 15`).

### Ingress & Security
*   **Domain:** Erreichbar über `admin.nix.m7c5.de`.
*   **Schutz:** Strikte Absicherung via Caddy + mTLS + Pocket-ID SSO.
*   **Protokoll:** Nutzt `X-Forwarded-Proto`, um dem Dienst mitzuteilen, dass die Verbindung ursprünglich über HTTPS kam.

### Integration (Nix-Snippet)
```nix
services.cockpit = {
  enable = true;
  port = 20001;
  settings = {
    WebService.AllowUnencrypted = true;
    Session.IdleTimeout = 15;
  };
};
```

## 3. Reasoning Layer (History)

### [ADR-071] Cockpit vs. Webmin/Ajenti
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Viele Web-Admin Tools bringen eigene Daemons und Datenbanken mit, die das System "verschmutzen".
*   **Entscheidung:** Nutzung von Cockpit.
*   **Vorteil:** Cockpit ist ein offizielles Projekt von Red Hat, extrem schlank und nutzt direkt die vorhandenen Linux-Systemdienste (systemd, journald, NetworkManager/networkd). Es erzeugt keinen eigenen State außerhalb der Standard-Linux-Pfade.

---
**Community-Abgleich:** Konform zu NixOS-Standards
