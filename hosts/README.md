---
title: "Host Configurations"
status: active
---

# 📖 hosts — Machine Configurations

> **Zweck:** Per-Machine Konfigurationen — Hardware, Identity, Modul-Imports.

Jeder Sub-Ordner hier repräsentiert eine physische oder virtuelle Maschine.

---

## 📋 Regeln

- **Hardware-UUIDs** gehören in `hardware-nixos.nix` (nixos-generate-config output)
- **Modul-Imports** werden pro Host aktiviert/deaktiviert (nicht jeder Host braucht alle Module)
- **`configuration.nix`** enthält Boot, Identity, Impermanence, SOPS
- **`default.nix`** importiert configuration + hardware

---

## 🏗️ Struktur

| Host | Zweck |
|------|-------|
| [q958](q958/) | Fujitsu Q958 Server — Headless, Impermanence, Media-Stack |
| [laptop](laptop/) | Laptop — Mobile, kein Impermanence |

---

## 🔗 Verknüpfungen

- **Modules:** `../../modules/` — Domains die importiert werden
- **Users:** `../../users/` — User die auf dem Host aktiv sind
- **Templates:** `../../_templates/TPL_Host_config.nix`, `TPL_Host_hardware.nix`
