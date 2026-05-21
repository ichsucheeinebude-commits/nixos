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
