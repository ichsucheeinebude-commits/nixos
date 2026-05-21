---
domain: 00
id: "NIXH-00-COR-003"
title: "Nix Tuning"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,nix,gc]
description: "Nix daemon tuning and GC configuration."
path: "docs/adr/ADR-02-nix-tuning.md"
links:
  module: "modules/placeholder.nix"
---

# ADR: Nix Tuning

## Context\nNix store grows unbounded without GC. We need sane defaults.\n## Decision\nEnable automatic weekly GC, auto-optimise-store, and flakes by default.\n## Consequences\nStore stays manageable; flakes are the standard workflow.
