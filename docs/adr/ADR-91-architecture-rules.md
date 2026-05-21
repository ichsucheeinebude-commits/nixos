---
domain: 90
id: "NIXH-90-POL-002"
title: "Architecture Rules"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [policy,architecture]
description: "Architecture guard rails."
path: "docs/adr/ADR-91-architecture-rules.md"
links:
  module: "modules/90-policy/91-architecture-rules.nix"
---

# ADR: Architecture Rules

## Decision
Build-time assertions prevent architectural drift.


---

## KB Nuggets

=== Architecture Evolution Strategy
Von Monolith zu Dendritic. Jeder Schritt ist reversibel. Feature-Oriented statt Class-Oriented.
=== Flake Parts Architecture
Auto-Import via import-tree. Deferred Modules für Konflikt-Minimierung. No specialArgs needed.
