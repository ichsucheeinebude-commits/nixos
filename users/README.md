---
title: "User Configurations"
status: active
---

# 📖 users — Home-Manager User Configs

> **Zweck:** Per-User Home-Manager Konfigurationen — Packages, Dotfiles, Preferences.

Jeder Sub-Ordner hier repräsentiert einen System-User mit seiner eigenen Home-Manager-Umgebung.

---

## 📋 Regeln

- **`default.nix`** — System-User Anlage (users.users.NAME)
- **`home.nix`** — Home-Manager Config (packages, programs, stateVersion)
- **`preferences.nix`** — Optionale User-spezifische Einstellungen
- **Template:** `_templates/TPL_User_default.nix`, `TPL_User_home.nix`

---

## 🏗️ Struktur

| User | Zweck |
|------|-------|
| [moritz](moritz/) | Hauptuser — Admin, wheel, voller Zugriff |
| [freund](freund/) | Gast-User — Eingeschränkte Rechte |

---

## 🔗 Verknüpfungen

- **Hosts:** `../hosts/` — Welche Hosts haben diesen User?
- **Core:** `../modules/00-core.nix` — Shell-Aliases, System-Packages
- **Template:** `../_templates/TPL_User_default.nix`, `TPL_User_home.nix`
