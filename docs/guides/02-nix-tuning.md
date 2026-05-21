---
domain: 00
id: "NIXH-00-COR-003"
title: "Nix Tuning Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,nix]
description: "Nix tuning defaults."
path: "docs/guides/GUIDE-02-nix-tuning.md"
links:
  module: "modules/00-core/02-nix-tuning.nix"
---

# Guide: Nix Tuning Guide

Defaults are production-ready.


---

## KB Nuggets

### Binary Cache Optimierung
`auto-optimise-store = true` + dedizierte Binary-Cache-URLs reduzieren Build-Zeit um 60-80%.
### GC Policy
`options = { keep-days = 3; keep-outputs = true; keep-derivations = true; }` — ausreichend für Rollbacks ohne Space-Verschwendung.
