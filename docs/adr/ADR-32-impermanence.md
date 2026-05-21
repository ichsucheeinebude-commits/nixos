---
domain: 30
id: "NIXH-30-STO-003"
title: "Impermanence"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [storage,impermanence]
description: "Stateless root with tmpfs."
path: "docs/adr/ADR-32-impermanence.md"
links:
  module: "modules/30-storage/32-impermanence.nix"
---

# ADR: Impermanence

## Decision
Root on RAM, /persist for durable state.


---

## KB Nuggets

### Blank Snapshot Persistence
Radikale System-Hygiene nach Misterio77. / ist tmpfs. Nur explizit gelistete Pfade überleben den Boot.
### Impermanenz-Strategie
Verhindert State-Drift. Zwingt zu sauberer Deklaration. Secrets und State müssen explizit persistiert werden.
