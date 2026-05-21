---
domain: 00
id: "NIXH-00-COR-001"
title: "Principles Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
source: "https://github.com/vic/den"
tags: [core,principles]
description: "How to use principles."
path: "docs/guides/GUIDE-00-principles.md"
links:
  module: "modules/00-core/00-principles.nix"
---

# Guide: Principles Guide

## Usage

### ---

title: 🛡️ Aviation-Grade Hardening (srvos Pattern)
category: architecture/security
status: [ACTIVE-SSoT]
capabilities: [process-isolation, systemd-sandboxing, gpu-binding, srvos-standard]
sources: [numtide/srvos, systemd.exec(5)]
---

# 🛡️ Hardening: Der srvos-Standard

In mynixos nutzen wir das **srvos Pattern** (Numtide), um Dienste maximal zu isolieren, ohne die Hardware-Beschleunigung zu verlieren.

### 🏛️ 1. Das GPU-Paradoxon gelöst

Bisher bedeutete GPU-Zugriff oft den Verzicht auf \`PrivateDevices\`. Wir nutzen jetzt **BindPaths**.
- **Konzept:** Wir setzen \`PrivateDevices = true\`, binden aber den Render-Node explizit wieder in den Sandbox-Namespace ein.
- **Vorteil:** Der Dienst sieht die GPU, aber keine anderen physischen Geräte des Hosts. ✅

### ⚙️ 2. Der Hardening-Blueprint

Jeder Dendrit folgt diesem Sicherheits-Standard in der \`serviceConfig\`:
\`\`\`nix
NoNewPrivileges = true;
ProtectSystem = "strict";
ProtectHome = true;
PrivateTmp = true;
PrivateDevices = true;
BindPaths = [ "/dev/dri/renderD128" ]; # Nur wenn GPU nötig
CapabilityBoundingSet = [ "" ];
\`\`\`

### 🚀 SRE-Vorteil

Dieser Standard senkt die Angriffsfläche drastisch. Ein kompromittierter Dienst kann weder das Dateisystem modifizieren noch andere Hardware-Komponenten scannen.
```nix
my.core.principles.bastelmodus = true;  # enable experimental
```


---

## KB Nuggets

### Boot-Kaskade Implementierung
| Szenario | Key-Faktor | User-Aktion |
|---|---|---|
| Identische Hardware | TPM2 (PCR 0+1+7) | Keine |
| Heimnetz | Tang-Server / MAC-DNA | Keine |
| Fremdnetz | FIDO2 (YubiKey) | 1x Button |
| Totaler Wechsel | SSH via Smartphone | Passwort pasten |
### ZFS-Optimierung für Tier A (NVMe)
| Option | Wert | Rationale |
|---|---|---|
| ashift | 12 | 4K NAND-Alignment |
| compression | zstd | Max Durchsatz, min CPU |
| xattr | sa | Metadaten im Inode |
| atime | off | SSD-Schutz |
| autotrim | on | Echtzeit-Bereinigung |
### ABC Storage Tiering
- **Tier A (NVMe):** OS, Appdata, ZFS (Samsung PM961 500GB)
- **Tier B (SSD):** Download-Cache (Apacer 250GB, WLAN-Slot)
- **Tier C (HDD):** Medien-Archiv (2× HDD, SATA + DVD-Caddy)
