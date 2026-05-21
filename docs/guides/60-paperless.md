---
domain: 60
id: "NIXH-60-APP-001"
title: "Paperless Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
source: "https://github.com/paperless-ngx/paperless-ngx, NixOS Manual"
tags: [apps,paperless]
description: "Configure Paperless."
path: "docs/guides/GUIDE-60-paperless.md"
links:
  module: "modules/60-apps/60-paperless.nix"
---

# Guide: Paperless Guide

```nix
my.apps.paperless.enable = true;
```


---

## KB Nuggets

=== Paperless Master-Config
OCR: Tesseract (de+en). Consumedir: /persist/paperless/consume. Media: Tier A. Export: Restic-Backup.
=== Paperless Master-Variable-List
Komplette Referenz aller 40+ Konfigurationsvariablen mit Defaults und Beschreibung.

---
## Paperless MASTER-CONFIG (from KB)

---
title: 📄 Paperless-ngx Master-Config (Layer 50-knowledge)
category: architecture/services
status: [ACTIVE-SSoT]
capabilities: [declarative-configuration, ocr-optimization, lightweight-db]
sources: [https://github.com/paperless-ngx/paperless-ngx, NixOS Manual]
---

# 📄 Paperless-ngx: Dein digitales Archiv

In mynixos nutzen wir Paperless-ngx nativ für maximale Performance und totale deklarative Kontrolle.

## 🏛️ Architektur-Entscheidungen (Efficiency Standard)
1.  **Datenbank:** Wir nutzen **SQLite**. Für den Heimgebrauch (Tower) ist SQLite hocheffizient und benötigt keinen extra Datenbank-Daemon (RAM-Ersparnis).
2.  **Storage:** Alle Dokumente liegen in \`/persist/var/lib/paperless/media\` (Impermanence Standard).
3.  **OCR:** Wir nutzen \`PAPERLESS_OCR_LANGUAGE = "deu+eng"\`.

## ⚙️ Deklarative Nix-Konfiguration
Hier ist das Muster für deinen Dendriten (\`modules/50-knowledge/paperless.nix\`):

\`\`\`nix
services.paperless = {
  enable = true;
  address = "0.0.0.0";
  port = 28981;
  settings = {
    # Hier kommen alle App-Variablen rein!
    PAPERLESS_TIME_ZONE = "Europe/Berlin";
    PAPERLESS_OCR_LANGUAGE = "deu+eng";
    PAPERLESS_OCR_MODE = "clean";
    PAPERLESS_AUTO_LOGIN_USERNAME = "admin"; # Nur lokal sicher!
    PAPERLESS_FILENAME_FORMAT = "{{created_year}}/{{correspondent}}/{{title}}";
  };
  # Secrets (API-Keys etc.) kommen hier rein:
  environmentFile = config.sops.secrets."paperless/env".path;
};
\`\`\`

## 🛡️ SRE-Hardening
- Der Dienst wird via Caddy (Layer 20) über \`paperless.m7c5.de\` mit mTLS abgesichert.
- Der Konsum-Ordner (\`consumptionDir\`) wird für den Scanner im Netzwerk freigegeben.
