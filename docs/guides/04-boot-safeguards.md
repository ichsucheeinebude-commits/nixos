---
domain: 00
id: "NIXH-00-COR-005"
title: "Boot Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,boot]
description: "Configure boot safeguards."
path: "docs/guides/GUIDE-04-boot-safeguards.md"
links:
  module: "modules/00-core/04-boot-safeguards.nix"
---

# Guide: Boot Guide

```nix
my.core.boot.configurationLimit = 10;
```


---

## KB Nuggets

### systemd-boot Safeguards
- Automatische alte-Generation-Bereinigung
- /boot-Overflow-Protection via pre-built Hook
- GC-Trigger nach jedem switch

---
## Boot Safeguard (from KB)

# Service: Boot Safeguard (Stability & Overflow Protection)

## 1. User Layer (KISS)
Dieses Dokument beschreibt die "Versicherung" deines Servers. NixOS speichert bei jeder Änderung eine alte Version des Systems, damit du immer zurückkehren kannst. Das Problem: Irgendwann ist der Speicherplatz für den Startvorgang (`/boot`) voll und der Server startet nicht mehr. Dieses Modul räumt automatisch auf, prüft täglich den freien Speicherplatz und bietet dir im Notfall einen RAM-Test direkt beim Start an.

## 2. Technical Layer (Aviation-Grade)

### Maintenance-Logik
*   **Garbage Collection:** Täglicher Lauf (`nix.gc`). Löscht alle System-Generationen, die älter als 7 Tage sind.
*   **Bootloader-Hardening:** Begrenzung auf maximal 5 Generationen im Boot-Menü (`configurationLimit = 5`).
*   **Hardware-Diagnose:** Aktivierung von `memtest86` als Boot-Option.

### Operatives Monitoring
*   **`boot-space-check`:** CLI-Tool zur Prüfung der ESP-Partition. Bricht mit Fehler ab, wenn > 85% belegt sind.
*   **Sicherer Rebuild (`nsw-safe`):** Ein Alias, der erst den Speicher prüft und nur bei Erfolg den System-Rebuild startet.

### Integration (Nix-Snippet)
```nix
boot.loader.systemd-boot = {
  enable = true;
  configurationLimit = 5;
  memtest.enable = true;
};
```

## 3. Reasoning Layer (History)

### [ADR-024] Aggressive GC vs. Generation History
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Auf dem Fujitsu Q958 ist die EFI-Partition oft begrenzt. Ein Vollaufen führt zu korrupten Bootloader-Einträgen.
*   **Entscheidung:** Wir priorisieren Systemsicherheit (freier Speicher) vor einer langen Historie.
*   **Vorteile:** Deterministisches Verhalten bei Updates. Durch den Pre-Flight Check in `nsw-safe` wird ein unvollständiger Schreibvorgang auf `/boot` proaktiv verhindert.

---
**Sources:**
*   `00-core/boot-safeguard.nix`

