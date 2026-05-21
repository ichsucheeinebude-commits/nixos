---
domain: 30
id: "NIXH-30-STO-004"
title: "Storage Policy Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [storage,policy]
description: "Storage policy guide."
path: "docs/guides/GUIDE-33-storage-policy.md"
links:
  module: "modules/30-storage/33-storage-policy.nix"
---

# Guide: Storage Policy Guide

Assertions prevent misconfiguration.


---

## KB Nuggets

=== Storage Mover v5.3
Python-Skript das A ↔ B Daten verschiebt. Snapshot VOR Evakuierung. rsync mit Verify. Rollback bei Fehler.

---
## Disk Discovery HAL (from KB)

# 📀 [SERVICES]: Disk Discovery & Pending-Handler (v4.2)

## 👤 1. USER LAYER (KISS)
"Oma-Logik": Wir sorgen dafür, dass dein System nie den Anschluss verliert, wenn du eine neue Festplatte anschließt.
- **Problem:** Normalerweise bricht das System beim Starten ab, wenn eine Festplatte fehlt, die eigentlich da sein sollte.
- **Lösung:** Wir trennen den Start des Systems vom Finden der Festplatten. Wenn eine Festplatte fehlt, wird sie als "wartend" (pending) markiert und ein Alarm in deinem Dashboard (Homepage) ausgelöst.
- **Vorteil:** Dein System startet immer zuverlässig, auch wenn eine Festplatte kaputt ist oder nicht angeschlossen wurde.

---

## ⚙️ 2. TECHNICAL LAYER (AVIATION-GRADE)
Spezifikation des Disk-Handlings (`00-core/hal-disk-discovery.nix`).

### 🛠️ 2.1 Drei-Phasen-Ansatz
1.  **udev Erkennung:** Automatische Identifizierung neuer Datenträger via udev-Regeln.
2.  **Systemd Mount-Services:** Dynamische Mounts (`WantedBy = ["multi-user.target"]`) statt statischer `/etc/fstab` Einträge. Verhindert Boot-Abbruch bei fehlender Hardware.
3.  **Pending-Handler:** Unbekannte Disks landen in einer Queue. Es wird automatisch ein JSON für Homepage-Widgets und OliveTin-Aktionen generiert.

### 📜 2.2 OliveTin Integration
- Ermöglicht das interaktive Zuweisen (Labeln) einer neuen Disk zu einem Tier (A, B oder C) direkt über die Weboberfläche.

---

## 🧠 3. REASONING LAYER (HISTORY)
Architektonische Herleitung:
- **Resilienz:** Ein Homelab muss robust gegenüber Hardware-Ausfällen sein. Die herkömmliche `nofail`-Option in fstab reicht nicht aus, da Dienste oft in leere Mount-Points schreiben, wenn die Disk fehlt.
- **Benutzerführung:** Statt kryptischer Logs im Terminal bekommt der Nutzer eine klare Handlungsanweisung im Dashboard ("Neue Disk gefunden -> Hier labeln").

> [SOURCE-ENRICHMENT]: Extracted from `Claude-03 Prompt-Übernahme anfragen.md` (Conversational SRE Review 3.3.2026).

