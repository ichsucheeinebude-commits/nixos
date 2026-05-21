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
