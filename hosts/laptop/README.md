---
title: "Host: laptop"
status: active
---

# 📖 laptop — Laptop Konfiguration

> **Zweck:** Mobile NixOS Konfiguration — kein Impermanence, reduzierte Services.

---

## 🏗️ Dateien

| Datei | Zweck |
|-------|-------|
| `configuration.nix` | Host-Konfiguration: Boot, Identity, SOPS, Modul-Imports |
| `hardware-nixos.nix` | Hardware-UUIDs, Kernel-Module (nixos-generate-config output) |
| `default.nix` | Import-Wrapper für configuration + hardware |

---

## 🔗 Verknüpfungen

- **Modules:** `../../modules/` — 00-core, 10-network, 20-security (weitere nach Bedarf)
- **Users:** `../../users/` — moritz
