---
domain: 40
id: "NIXH-40-MON-005"
title: "Vector Log Aggregator"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [monitoring,vector]
description: "Vector log pipeline."
path: "docs/adr/ADR-44-vector.md"
links:
  module: "modules/40-monitoring/44-vector.nix"
---

# ADR: Vector Log Aggregator

## Decision
Journald → file output pipeline.


---

## KB Nuggets

=== Vector Log Pipeline
Sammelt Logs von allen Services. Filtert, transformiert, routed. Ersatz für ELK-Stack.
