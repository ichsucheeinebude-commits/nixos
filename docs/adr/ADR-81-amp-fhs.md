---
domain: 80
id: "NIXH-80-GAM-002"
title: "AMP FHS Sandbox"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [gaming,amp,fhs]
description: "FHS sandbox for AMP."
path: "docs/adr/ADR-81-amp-fhs.md"
links:
  module: "modules/80-gaming/81-amp-fhs.nix"
---

# ADR: AMP FHS Sandbox

## Decision
buildFHSEnv with dotnet-sdk and dependencies.


---

## KB Nuggets

=== AMP FHS Wrapper
FHS-User-Environment für AMP-Spiele die /srv/ erwarten.
