---
domain: 00
id: "NIXH-00-COR-003"
title: "Nix Tuning"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,nix,gc]
description: "Nix daemon tuning and GC."
path: "docs/adr/ADR-02-nix-tuning.md"
links:
  module: "modules/00-core/02-nix-tuning.nix"
---

# ADR: Nix Tuning

## Decision
Weekly GC, auto-optimise-store, flakes enabled by default.


---

## KB Nuggets

### Binary-Only Policy
`allowUnfree = false` + `allowedRequisites = all` verhindert Source-Builds und supply-chain Angriffe.
### nix-eval als Parser
Statt Python-Regex nutzen wir `nix eval` für sauberes JSON aller Modul-Metadaten. Keine Phantom-IDs mehr.

---
## KB Nuggets

### ---

title: ⚙️ Nixpkgs Engine Mastery (Architecture Core)
category: architecture/core
status: [ACTIVE-SSoT]
capabilities: [kernel-management, package-overlays, by-name-standard]
sources: [nixpkgs/pkgs/top-level/]
---

# ⚙️ Nixpkgs Engine: Unter der Haube

Um mynixos auf Aviation-Grade Level zu betreiben, müssen wir verstehen, wie der Engine-Room von Nixpkgs funktioniert.

### 🏛️ 1. Kernel Management (Layer 00-core)

In `engine-linux-kernels.nix` sehen wir, wie Kernel deklariert werden.
- **Pattern:** Wir können für den Tower gezielt den `linuxPackages_latest` oder `linuxPackages_hardened` wählen.

### 🧩 2. Der By-Name Standard

Nixpkgs nutzt das `pkgs/by-name` Pattern. Wir kopieren diesen Standard für unsere eigenen Pakete in `mynixos/pkgs/`.
- **Vorteil:** Automatische Erkennung von Paketen ohne manuelle Imports in `all-packages.nix`.

### ⚙️ 3. Globale Konfiguration (`config.nix`)

Hier deklarieren wir systemweite Nixpkgs-Einstellungen:
- `allowUnfree = true;` (Nötig für Intel-Treiber).
- `permittedInsecurePackages = [ ... ];` (Nur im Notfall!).

