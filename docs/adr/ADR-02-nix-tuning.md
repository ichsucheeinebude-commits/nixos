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
