---
domain: 00
id: "NIXH-00-COR-001"
title: "Principles & Defaults"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
source: "https://github.com/vic/den"
tags: [core,principles]
description: "Global enable + bastelmodus toggle."
path: "docs/adr/ADR-00-principles.md"
links:
  module: "modules/00-core/00-principles.nix"
---

# ADR: Principles & Defaults

## Context
We need a master toggle for all core modules and an experimental flag.

## Decision

### ---

title: "The Den Framework: Architectural Foundation"
category: "adr"
tags: [nixos, den, dendritic, architecture, framework, flake-parts]
date: 2026-03-08
source: "https://github.com/vic/den"
status: "live-validated-v6.6-definitive"
---

# 🏗️ [ADR-INFO]: DEN & THE DENDRITIC PATTERN (DEFINITIVE EDITION)

Dieses Dokument definiert das Framework-Fundament der mynixos Distribution. Es basiert auf dem Dendritic-Pattern, das radikale Modularität durch die Umkehrung der Import-Logik erreicht.

---

### 🏗️ 1. USER LAYER: MODULARITÄT OHNE SCHMERZ (KISS)

In herkömmlichen Nix-Systemen musst du jede neue Datei manuell in einer Liste eintragen. In unserem System ist das vorbei:
- **Prinzip:** "Jede Datei ist ein Modul".
- **Aktion:** Erstelle eine `.nix` Datei im Ordner `features/` – sie wird sofort vom System erkannt und geladen.
- **Vorteil:** Du kannst dich auf das Konfigurieren konzentrieren, anstatt dich um Import-Strukturen zu kümmern.

---

### A. Die Engine: `flake-parts` & `den`

Wir nutzen `flake-parts` als Basis und das `den` Framework zur Kontext-Steuerung.
- **Auto-Import:** Integration von `import-tree`, um das gesamte Verzeichnis `./modules` rekursiv zu evaluieren.
- **Deferred Modules:** Wir nutzen den Typ `deferredModule` aus Nixpkgs für Sub-Module, um Konflikte beim Mergen von Attributen (z.B. Firewall-Regeln) zu minimieren.

### B. Das "Aspect" Modell

Ein Aspekt definiert eine funktionale Einheit (z.B. `gaming` oder `media-server`), die klassenübergreifend agiert:
```nix
{ den, ... }: den.aspect {
  # Konfiguration für NixOS
  nixos = { ... };
  # Konfiguration für Home-Manager (User-Ebene)
  homeManager = { ... };
}
```

---

### Warum der Verzicht auf `specialArgs`?

In einer echten dendritischen Architektur haben alle Module Zugriff auf den globalen `config` Scope. Dies eliminiert die Notwendigkeit, Variablen mühsam durch Tunnel (`specialArgs`) zu reichen, was die Fehleranfälligkeit bei großen Setups massiv reduziert.
- my.core.principles.enable controls whether core is active.
- my.core.principles.bastelmodus defaults to false (strict mode).


---

## KB Nuggets

### Zero-Touch Boot-Kaskade
Das System bootet vollautomatisch auf bekannter Hardware (TPM2), benötigt FIDO2-PIN auf fremder Hardware, und SSH-Unlock als letzte Instanz.
### Impermanenz (Hotelzimmer-Prinzip)
Das OS ist bei jedem Start frisch. Alles nicht explizit Persistierte existiert nur im RAM (tmpfs). Verhindert State-Drift und erzwingt saubere Deklarationen.
### HAL (Hardware Abstraction Layer)
Software ist blind für Hardware. Anfragen (z.B. Transcoding) laufen über abstrakte HAL-Optionen statt direkter Hardware-Referenzen.
