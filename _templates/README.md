---
title: "Templates"
status: active
---

# 📖 _templates — Blanko-Vorlagen

> **Zweck:** Kanonische Templates für neue ADRs, Guides, Module, Hosts und User-Konfigurationen.

Jedes Template hier enthält den kanonischen YAML-Metadaten-Header (domain, id, title, type, links) und die korrekte Grundstruktur.

---

## 📋 Regeln

- **Template kopieren → anpassen → umbenennen** — nie direkt im Template arbeiten
- **Jedes Template hat den kanonischen NIXMETA-Header** — nicht entfernen
- **REPLACE_XXX-Platzhalter** müssen vor dem Speichern ersetzt werden
- **Template-Nummerierung muss zur Domain passen** (Domain 20 → ADR-20, Guide 20, Modul 20)

---

## 🏗️ Struktur

| Template | Zweck |
|----------|-------|
| [TPL_ADR.md](TPL_ADR.md) | Architecture Decision Record — Frontmatter + Context/Alternatives/Decision/Consequences/Rollback/Validation |
| [TPL_Guide.md](TPL_Guide.md) | Operational Guide — Prerequisites/How It Works/Procedures/Verification/Troubleshooting |
| [TPL_Nix_Module.nix](TPL_Nix_Module.nix) | NixOS-Modul — NIXMETA-Header + options/config + Systemd-Service + User |
| [TPL_Host_config.nix](TPL_Host_config.nix) | Host-Konfiguration — Boot/Identity/Impermanence/SOPS |
| [TPL_Host_hardware.nix](TPL_Host_hardware.nix) | Hardware-Config — nixos-generate-config output |
| [TPL_User_default.nix](TPL_User_default.nix) | User-Anlage — users.users.NAME |
| [TPL_User_home.nix](TPL_User_home.nix) | Home-Manager — packages/programs/stateVersion |
| [TPL_Gemini.md](TPL_Gemini.md) | AI-Kontext — Verhaltensregeln, Verbote, Verknüpfungen pro Ordner |
| [TPL_README.md](TPL_README.md) | Ordner-README — Zweck/Regeln/Struktur/Verknüpfungen |

---

## 🔗 Verknüpfungen

- **Docs:** `../docs/` — Hier werden ADRs und Guides abgelegt
- **Modules:** `../modules/` — Hier werden Nix-Module abgelegt
- **Hosts:** `../hosts/` — Hier werden Host-Configs abgelegt
- **Users:** `../users/` — Hier werden User-Configs abgelegt
