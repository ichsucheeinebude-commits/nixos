---
domain: 00
id: "NIXH-00-COR-004"
title: "Hardware Profile"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,hardware]
description: "CPU microcode and GPU drivers."
path: "docs/adr/ADR-03-hardware-profile.md"
links:
  module: "modules/00-core/03-hardware-profile.nix"
---

# ADR: Hardware Profile

## Decision
Conditional on cpuType and intelGpu options.


---

## KB Nuggets

### Fujitsu q958 Hardware-Layout
Intel i3-9100, 16GB RAM, Intel UHD 630 (QuickSync). M.2 Main: Samsung PM961 500GB. M.2 WLAN: Apacer 250GB (SATA). 2× HDD (SATA + DVD-Caddy).
### Intel QuickSync Transcoding
`intel-compute-runtime` (nicht deprecated `intel-media-sdk`) für Hardware-Transcoding in Jellyfin.

---
## Hardware Reference (from KB)

---
title: "Hardware Specification: Fujitsu Esprimo Q958"
category: "adr"
tags: [hardware, q958, storage, layout, nvme, sata]
date: 2026-03-08
source: "claude-genesis-log-11f6d76e"
status: "verified-substance-definitive"
---

# 🏛️ [ADR-INFO]: HARDWARE LAYOUT & STORAGE MAPPING (Q958)

Dieses Dokument definiert die physische Basis der mynixos Distribution auf dem Fujitsu Esprimo Q958 (Intel i3-9100, 16GB RAM).

---

## 🏗️ 1. USER LAYER: DAS GEHÄUSE-LAYOUT (KISS)
Wir nutzen jeden Millimeter des Q958 aus:
- **Schnell:** Das System und alle Apps leben auf der Haupt-NVMe.
- **Puffer:** Downloads landen auf einer zweiten SSD im WLAN-Slot.
- **Massenspeicher:** Filme und Serien liegen auf zwei internen HDDs (eine davon im DVD-Schacht).
- **Backup:** Eine externe Platte sichert alles ab.

---

## 🛠️ 2. TECHNICAL LAYER: STORAGE MAPPING

| Slot | Komponente | Rolle | Anbindung |
| :--- | :--- | :--- | :--- |
| **M.2 Main** | Samsung 500GB (PM961) | **Tier A:** OS, Appdata, ZFS | NVMe PCIe x4 |
| **M.2 WLAN** | Apacer 250GB | **Tier B:** Download Cache | SATA / PCIe x2 (Adapter) |
| **SATA 2.5"** | HDD 1 (Media) | **Tier C:** Archiv | SATA |
| **DVD Caddy** | HDD 2 (Media) | **Tier C:** Archiv | SATA |
| **USB 3.0** | HDD 3 (External) | **Backup:** Restic Vault | USB |

### Die A+E Key Limitation
Der WLAN-Slot des Q958 stellt physisch nur 2 PCIe Lanes (oder SATA) bereit. Eine schnelle NVMe SSD würde hier auf halber Geschwindigkeit laufen. Daher nutzen wir diesen Slot exklusiv für den **Download-Cache (Tier B)**, wo SATA-Speed (ca. 500MB/s) völlig ausreicht.

---

## 📜 3. REASONING LAYER: HERLEITUNG

### Warum Samsung für Tier A?
Die Samsung PM961 ist eine Pro-Level SSD mit hoher Schreib-Resistenz (DWPD). Da Tier A durch ZFS und Datenbanken die höchste IO-Last hat, ist die Wahl der hochwertigeren Platte hier essenziell für die System-Langlebigkeit.

### Warum DVD-Caddy statt externes Gehäuse?
Interne SATA-Anbindung ist stabiler und performanter als USB-Brücken für den Dauerbetri
