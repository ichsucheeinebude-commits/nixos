---
domain: 50
id: "NIXH-50-MED-001"
title: "Media Library Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
source: "nixarr, nixflix, Internal SRE Audit"
tags: [media,library]
description: "Configure media paths."
path: "docs/guides/GUIDE-50-lib-media.md"
links:
  module: "modules/50-media/50-lib-media.nix"
---

# Guide: Media Library Guide

Set paths in host config.


---

## KB Nuggets

=== Media Library Base
Tier C (HDD) als readonly für Jellyfin/Sonarr/Radarr. Tier B (SSD) als RW für Downloads/Transcoding.

---
## Media Stack Hardening (from KB)

---
title: "Media Stack Hardening: VPN, RO-Mounts & Recyclarr"
category: "services"
tags: [security, hardening, jellyfin, sabnzbd, vpn, recyclarr]
date: 2026-03-08
source: "claude-genesis-log-11f6d76e"
status: "verified-substance-definitive"
---

# 🏗️ SERVICE: MEDIA STACK HARDENING & AUTOMATION

Dieses Dokument definiert die spezifischen Sicherheits- und Automatisierungs-Einstellungen für die Media-Services.

---

## 🛡️ 1. JELLYFIN: READ-ONLY MEDIATHEK
Jellyfin hat keinen Grund, physisch in die Filmdateien zu schreiben.
- **Konzept:** `BindReadOnlyPaths`.
- **Vorteil:** Verhindert, dass Jellyfin bei einem Exploit oder Software-Bug Mediendaten löscht oder korrumpiert.
- **Implementierung:**
```nix
systemd.services.jellyfin.serviceConfig.BindReadOnlyPaths = [
  "/data/media:/var/lib/jellyfin/media"
];
```

---

## 🔐 2. SABNZBD: VPN-NAMESPACE KILLSWITCH
Der Downloader darf NIEMALS ohne VPN-Tunnel kommunizieren.
- **Konzept:** Network Namespaces (netns).
- **Logik:** SABnzbd startet in einem isolierten Namespace, der physisch nur das `tun0` (WireGuard) Interface sieht.
- **Sicherheit:** Wenn der VPN-Tunnel fällt, ist SABnzbd offline. Es gibt keine Leak-Gefahr durch falsche IP-Bindungen.

---

## ⚙️ 3. RECYCLARR: TRaSH-GUIDE AUTOMATION
Optimale Qualität ohne manuelles Gefrickel.
- **Dienst:** `services.recyclarr.enable = true`.
- **Funktion:** Synchronisiert automatisch die "Best-of" Profile für Sonarr und Radarr (z.B. bevorzugtes Release-Format, Ausschluss von schlechten Encodern).

---

## 📈 4. SPEICHER-OPTIMIERUNG (ZUKUNFTS-VISOIN)
- **Nahziel:** 250GB SSD als exklusiver Download-Cache (Tier B), damit die HDDs im Spindown bleiben.
- **Mover-Logik:** Nach 30 Tagen werden ungesehene Dateien auf Tier C verschoben oder (falls bereits konsumiert) gelöscht, um den HDD-Verschleiß zu minimieren.

