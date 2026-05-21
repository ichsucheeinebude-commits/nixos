---
domain: 60
id: "NIXH-60-APP-003"
title: "Vaultwarden Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [apps,vaultwarden]
description: "Configure Vaultwarden."
path: "docs/guides/GUIDE-62-vaultwarden.md"
links:
  module: "modules/60-apps/62-vaultwarden.nix"
---

# Guide: Vaultwarden Guide

Requires env secrets.


---

## KB Nuggets

=== Vaultwarden Setup
Admin-Token via SOPS. HTTPS nur via Caddy. Backup: verschlüsseltes SQLite-Dump. OIDC-Auth.

---
## Vaultwarden MASTER-CONFIG (from KB)

---
title: 📚 Vaultwarden MASTER-CONFIG (v1.0)
category: architecture/reference
status: [ACTIVE-SSoT]
sources: [https://github.com/dani-garcia/vaultwarden]
---

# 📚 Vaultwarden: Passwort-Sicherheit

Vaultwarden nutzt eine zentrale Environment-Datei zur Konfiguration.

## ⚙️ SRE-Anwendung
In NixOS nutzen wir \`services.vaultwarden\`.
- **Datenbank:** Standard SQLite (Aviation-Grade Efficiency).
- **Hardening:** \`services.vaultwarden.config\` erlaubt das Setzen aller Variablen (z.B. \`SIGNUPS_ALLOWED = false\`).

---
## Vaultwarden Service Config (from KB)

---
title: "Service: Vaultwarden (Aviation-Grade Password Manager)"
category: "services"
tags: [security, passwords, socket-activation, dendritic]
id: "NIXH-60-APP-007"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["60-apps/service-app-vaultwarden.nix"]
---

# Service: Vaultwarden (Secure Vault)

## 1. User Layer (KISS)
Vaultwarden ist dein Tresor für Passwörter. Es schützt deine Zugangsdaten mit modernster Verschlüsselung. Der Dienst schläft, solange er nicht gebraucht wird, und wacht blitzschnell auf, wenn du dein Browser-Plugin nutzt.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Ressourcen
* **Socket-Activation:** Minimiert RAM-Overhead im Leerlauf.
* **Backend:** Hochperformanter Rust-Port von Bitwarden.
* **Secrets:** Konfiguration via verschlüsselter Environment-Datei.

### SRE Hardening
* **Isolation:** MemoryDenyWriteExecute = true und striktes IP-Filtering.
* **Policy:** Öffentliche Registrierung ist deaktiviert.

## 3. Reasoning Layer (History)

### [ADR-066] No SSO for Vault
Vaultwarden wird bewusst nicht an das SSO-System angebunden, um eine Rettungsebene bei Ausfall des Identity Providers zu behalten.

