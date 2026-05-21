---
domain: 30
id: "NIXH-30-STO-004"
title: "Storage Policy"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [storage,policy]
description: "Storage policy assertions."
path: "docs/adr/ADR-33-storage-policy.md"
links:
  module: "modules/30-storage/33-storage-policy.nix"
---

# ADR: Storage Policy

## Decision
Enforce ABC tiering rules at build time.


---

## KB Nuggets

### Storage Policy Enforcement
MergerFS-Regeln definieren welche Daten wohin gehören. Automatische Migration bei Threshold-Überschreitung.
