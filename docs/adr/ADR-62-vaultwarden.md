---
domain: 60
id: "NIXH-60-APP-003"
title: "Vaultwarden"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [apps,vaultwarden]
description: "Vaultwarden password vault."
path: "docs/adr/ADR-62-vaultwarden.md"
links:
  module: "modules/60-apps/62-vaultwarden.nix"
---

# ADR: Vaultwarden

## Decision
Socket-activated, SSO-protected.


---

## KB Nuggets

=== Vaultwarden Password Vault
Leichtgewichtiger Bitwarden-Klon. Rust-basiert. PostgreSQL-Backend.

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
