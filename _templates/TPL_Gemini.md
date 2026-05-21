---
title: "AI Context – REPLACE_FOLDER"
scope: REPLACE_FOLDER
last_updated: YYYY-MM-DD
---

# 🤖 AI Context: REPLACE_FOLDER

## Was dieser Ordner tut
<!-- Kurzbeschreibung: Was liegt hier, wofür ist dieser Bereich? -->

## Verhaltensregeln (Pflicht)
1. **Kein Code ohne Anker** – Jede Nix-Datei braucht `# (anchor: NAME)`.
2. **Keine Dopplungen** – Prüfe zuerst ob Option/Service bereits existiert.
3. **NIXMETA aktuell halten** – Bei jeder Änderung `lastReviewed` updaten.
4. **ADR zuerst lesen** – Architekturentscheidungen stehen in der ADR, nicht hier.
5. **Keine `nixos-rebuild` Befehle** – Nur Dateioperationen.

## Verbote
- ❌ Keine Dateien löschen ohne Bestätigung
- ❌ Keine Domain-Nummern ändern
- ❌ Kein Code aus anderen Domains kopieren — Import verwenden

## Verknüpfte Dokumente
- ADR:   `../docs/adr/ADR-XX-REPLACE_FOLDER.md`
- Guide: `../docs/guides/XX-REPLACE_FOLDER.md`
- Modul: `../modules/XX-REPLACE_FOLDER.nix`

## Aktueller Status
<!-- Was ist in Arbeit? Was ist blockiert? -->
