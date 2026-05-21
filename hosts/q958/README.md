---
title: "Host: q958"
status: active
---

# 📖 q958 — Fujitsu Q958 Server

> **Zweck:** Headless Server Konfiguration — Impermanence, Media-Stack, alle Services.

---

## 🏗️ Dateien

| Datei | Zweck |
|-------|-------|
| `configuration.nix` | Host-Konfiguration: Boot, Identity, Impermanence, SOPS, Modul-Imports |
| `hardware-nixos.nix` | Hardware-UUIDs, Kernel-Module (nixos-generate-config output) |
| `default.nix` | Import-Wrapper für configuration + hardware |

---

## 🔗 Verknüpfungen

- **Modules:** `../../modules/` — 00-core bis 90-policy
- **Users:** `../../users/` — moritz, freund
