---
domain: 20
id: "NIXH-20-SEC-002"
title: "Kernel Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [security,kernel]
description: "Kernel hardening guide."
path: "docs/guides/GUIDE-21-kernel-hardening.md"
links:
  module: "modules/20-security/21-kernel-hardening.nix"
---

# Guide: Kernel Guide

Defaults are production-ready for headless servers.

---
## Security Hardening Baseline (from KB)

# 🛡️ [SERVICES]: Security Hardening Baseline (v4.2)

## 👤 1. USER LAYER (KISS)
"Oma-Logik": Wir bauen eine "digitale Gefängniszelle" für jedes Programm. Ein Programm (wie Jellyfin) kann nur das sehen und tun, was wir ihm ausdrücklich erlauben.
- **Problem:** Wenn ein Programm gehackt wird, hat der Angreifer oft Zugriff auf das gesamte System.
- **Lösung:** Jedes Programm läuft in seiner eigenen, extrem abgesicherten Umgebung. Es kann keine anderen Dateien sehen, keine anderen Programme beeinflussen und darf nur mit den Diensten sprechen, die es für seine Arbeit braucht.
- **Vorteil:** Maximale Sicherheit. Wenn ein Dienst fällt, bleibt der Rest des Systems sicher.

---

## ⚙️ 2. TECHNICAL LAYER (AVIATION-GRADE)
Spezifikation der Hardening-Maßnahmen (`00-core/lib-service-hardening.nix`).

### 🛡️ 2.1 Systemd Sandboxing (Profile)
Drei Hardening-Profile (`mkHardenedService`):
- **Web-Service (Standard):** `ProtectProc = "invisible"`, `RestrictAddressFamilies` (nur IPv4/v6/Unix), `MemoryDenyWriteExecute = true`.
- **Isolated (High-Security):** `PrivateNetwork = true`. Keine Netzwerk-Kommunikation außer über Unix-Sockets.
- **Hardware (Media):** Erlaubt Zugriff auf `/dev/dri` (GPU), behält aber alle anderen Restriktionen bei.

### 🕸️ 2.2 nftables Micro-Segmentation
- **Policy:** Jedes Programm darf nur mit explizit erlaubten Partnern sprechen (Whitelist).
- **skuid-Enforcement:** Regeln basieren auf der Service-UID im Kernel (`meta skuid`).
- **BPF-Filter:** Für Dienste mit dynamischen UIDs (`DynamicUser`) wird `IPAddressDeny/Allow` in Systemd genutzt.

---

## 🧠 3. REASONING LAYER (HISTORY)
Architektonische Herleitung:
- **Defense-in-Depth:** Sicherheit ist kein einzelnes Tool, sondern eine Schichtenarchitektur. Die Kombination aus Systemd-Sandboxing und Netzwerk-Filtern minimiert den "Blast Radius".
- **Aviation-Grade Standard:** Wir folgen den CIS (Center for Internet Security) Benchmarks für Linux. Hardening ist kein Luxus, sondern die Grundlage für einen stabilen Homeserver.

> [SOURCE-ENRICHMENT]: Extracted from `Claude-03 Prompt-Übernahme anfragen.md` (Conversational SRE Review 3.3.2026).

