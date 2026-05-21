---
domain: 10
id: "NIXH-10-NET-007"
title: "DNS Automation Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,dns]
description: "Configure DNS automation."
path: "docs/guides/GUIDE-16-dns-automation.md"
links:
  module: "modules/10-network/16-dns-automation.nix"
---

# Guide: DNS Automation Guide

Requires Cloudflare API token.


---

## KB Nuggets

### Subdomain-Registry
Reine Daten-Datei: Mapping von Service-Namen zu Subdomains. Kein Code, nur Konfiguration.

---
## DNS Automation Guard (from KB)

# Service: DNS Automation & Conflict Guard

## 1. User Layer (KISS)
Dieses Dokument beschreibt den "Verkehrspolizisten" deiner Internet-Adressen. Der Server prüft alle 30 Minuten bei Cloudflare, ob deine Web-Adressen (DNS) korrekt eingestellt sind. Falls es Konflikte gibt oder eine Adresse noch nicht bereit ist, merkt das System das automatisch und passt die interne Wegleitung an. So wird verhindert, dass Anfragen ins Leere laufen oder Sicherheitswarnungen im Browser erscheinen.

## 2. Technical Layer (Aviation-Grade)

### Architektur des DNS-Guards
Das Modul implementiert eine proaktive Validierung der externen Erreichbarkeit:
1.  **Check:** Ein systemd-Timer trigger einen `curl`-Request gegen die Cloudflare API.
2.  **Validierung:** Suche nach Wildcard-Einträgen (`*.deinedomain.de`) in deiner Zone.
3.  **State-Export:** Das Ergebnis wird als JSON nach `/var/lib/nixhome/dns-map-runtime.json` exportiert.
4.  **Integration:** Andere Dienste (wie der Reverse Proxy) können diese Datei lesen, um bedingte Routing-Entscheidungen zu treffen.

### Die Landing-Zone (Rettungs-UI)
Ergänzend zum DNS-Guard existiert eine statische "Landing Zone":
*   **Pfad:** `/var/www/landing-zone/`.
*   **Zweck:** Bereitstellung von mTLS-Zertifikaten und Notfall-Informationen.
*   **Technik:** Nutzung von `systemd.tmpfiles.rules`, um den Web-Inhalt direkt aus dem Nix-Store zu verlinken (unveränderlich und sicher).

### Integration (Nix-Snippet)
```nix
systemd.services.dns-guard = {
  serviceConfig.ExecStart = pkgs.writeShellScript "dns-guard" ''
    # API-Logik zur Cloudflare-Prüfung
    # ...
  '';
};
```

## 3. Reasoning Layer (History)

### [ADR-028] Dynamic DNS Validation vs. Static Declaration
*   **Status:** Entschieden (März 2026).
*   **Kontext:** DNS-Änderungen brauchen Zeit zum Propagieren. Ein lokaler Proxy, der auf eine nicht existierende externe Domain verweist, kann Timeouts und Fehlkonfigurationen verursachen.
*   **Entscheidung:** Einführung eines automatisierten Guards, der d
