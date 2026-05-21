---
domain: 60
id: "NIXH-60-APP-009"
title: "Monica Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [apps,monica]
description: "Configure Monica."
path: "docs/guides/GUIDE-68-monica.md"
links:
  module: "modules/60-apps/68-monica.nix"
---

# Guide: Monica Guide

```nix
my.apps.monica.enable = true;
```


---

## KB Nuggets

=== Monica Setup
Contact-Management, Reminders, Activities. Backup: PostgreSQL-Dump. OIDC-Auth.

---
## Monica CRM Service (from KB)

---
title: "Service: Monica (Aviation-Grade Personal CRM)"
category: "services"
tags: [knowledge, crm, contacts, dendritic]
id: "NIXH-60-APP-006"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["60-apps/service-app-monica.nix"]
---

# Service: Monica (Personal CRM)

## 1. User Layer (KISS)
Monica hilft dir dabei, deine sozialen Kontakte und Beziehungen zu pflegen. Es ist dein privates Tagebuch für Gespräche, Geburtstage und wichtige Details deiner Freunde und Familie.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Automatisierung
* **Backend:** PHP-FPM mit lokaler Datenbank.
* **Setup:** Automatische Generierung des App-Keys via Nix-Aktivierungsskript.
* **Pfad:** /var/lib/monica zur Speicherung von App-Daten.

### SRE Hardening
* **PHP-Sandbox:** Strenge Isolation des phpfpm-monica Dienstes.
* **Ingress:** Zugriff via Caddy mit mTLS und Pocket-ID SSO Schutz.

## 3. Reasoning Layer (History)

### [ADR-067] Monica vs. Nextcloud Contacts
Monica wird für tiefgehende Dokumentation genutzt, um über reine Kontaktadressen hinausgehende Interaktionshistorien abzubilden.

