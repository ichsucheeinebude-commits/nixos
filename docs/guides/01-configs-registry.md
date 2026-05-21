---
domain: "00"
id: "NIXH-00-CRG-001"
title: "Configs & Registry — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [ssot,registry,configs]
description: "How to configure the SSoT registry."
path: "docs/guides/01-configs-registry.md"
links:
  adr: "docs/adr/ADR-01-configs-registry.md"
  guide: "docs/guides/01-configs-registry.md"
  module: "modules/00-core/01-configs-registry.nix"
---

# 01-configs-registry — Configs & Registry (SSoT)

## Overview
SSoT für Identity, Hardware, Paths, Network.

## Configuration
```nix
my.core.identity.hostname = "q958";
my.core.identity.domain = "m7c5.de";
my.core.identity.user = "moritz";
```

## KB Nuggets
### configs.nix als SSO T Master
Identity (hostname, domain, user), Hardware (ramGB, cpu), Paths (media, backup), Network (ports) — alles an einem Ort.
### registry.nix Feature-Flags
Enable/disable Profile für Media, Forge, Gaming, Monitoring. Modules checken cfg.enable statt direkter Optionen.
### SSoT Registry Pattern
Alle Feature-Flags und Identitäts-Daten leben in einem zentralen Registry-Modul.
### Layer-Architektur (00-90)
Jede Datei muss sich durch die Kernfrage ihres Layers qualifizieren.

---
## Config Merger Bridge (from KB)

# Service: Hybrid Config Merger (Nix-to-JSON Bridge)

## 1. User Layer (KISS)
Dieses Dokument beschreibt den "Übersetzer" deines Systems. Da nicht alle Programme (wie Web-Oberflächen oder Skripte) die Sprache von NixOS verstehen, übersetzt dieses Modul deine wichtigsten Einstellungen (Domain, IP, E-Mail) automatisch in eine einfache JSON-Datei. Du kannst dort sogar eigene Einstellungen hinzufügen, die dann sofort vom System übernommen werden, ohne dass du den ganzen Server neu starten musst.

## 2. Technical Layer (Aviation-Grade)

### Architektur der Bridge
Das Modul agiert als SSoT-Exporteur für Nicht-Nix-Komponenten:
1.  **Export:** Nix-Optionen (`config.my.configs.*`) werden via `builtins.toJSON` in ein statisches Template geschrieben.
2.  **Merge:** Ein Oneshot-Systemd-Service nutzt `jq`, um das Nix-Template mit `/var/lib/nixhome/user-config.json` zu verschmelzen.
3.  **Deployment:** Das Ergebnis liegt in `/run/nixhome/config.json` (flüchtiger Speicher, immer aktuell).

### Das `nixhome-apply` CLI-Tool
Ermöglicht den schnellen Konfigurations-Reload:
*   **Logik:** Triggert den Merger-Service und führt anschließend gezielte Reloads durch (z.B. `systemctl reload caddy`).
*   **Vorteil:** Schnelle Iterationszyklen bei UI- oder Proxy-Anpassungen.

### Integration (Nix-Snippet)
```nix
systemd.services.nixhome-config-merger = {
  before = ["caddy.service" "pocket-id.service"];
  wantedBy = ["multi-user.target"];
  serviceConfig.ExecStart = mergerScript;
};
```

## 3. Reasoning
