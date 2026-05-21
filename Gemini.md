---
title: "AI Context – NixOS Root"
scope: root
last_updated: 2026-05-21
---

# 🤖 AI Context: NixOS Root

## Was dieses Projekt tut
Flake-basierte NixOS-Konfiguration für Q958 Server und Laptop. Impermanence, SOPS, Home-Manager.

## Verhaltensregeln (Pflicht)
1. **Kein Code ohne NIXMETA-Header** – Jede `.nix` Datei in `modules/` braucht den Kommentar-Block.
2. **Isomorphe Nummerierung** – Domain 20 = ADR-20 = Guide 20 = `20-security.nix`. Nie ändern.
3. **Kein lokales Kompilieren** – `max-jobs = 0` ist Pflicht. Binary-Only Policy.
4. **Keine `nixos-rebuild` Befehle** – Nur Dateioperationen.
5. **ADR zuerst lesen** – bevor du ein Modul änderst.

## Verbote
- ❌ Keine Dateien löschen ohne Bestätigung
- ❌ Keine Domain-Nummern ändern
- ❌ Keine Secrets im Repo (SOPS nur)

## Struktur
- `flake.nix` → Entry Point
- `hosts/` → Per-Machine Configs
- `modules/` → Domain Modules (00–90)
- `users/` → Home-Manager
- `docs/adr/` → Entscheidungen
- `docs/guides/` → Anleitungen
