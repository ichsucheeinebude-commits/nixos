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
