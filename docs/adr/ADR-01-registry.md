---
domain: 00
id: "NIXH-00-COR-002"
title: "Identity & Hardware Registry"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,identity,registry]
description: "Central registry for all identity, hardware, network, and port options."
path: "docs/adr/ADR-01-registry.md"
links:
  module: "modules/placeholder.nix"
---

# ADR: Identity & Hardware Registry

## Context\nWe need a single place to define host identity, hardware specs, network CIDRs, and service toggles.\n\n## Decision\nAll identity/hardware/port options live in my.core.*. Each service in the boilerplate has a toggle in my.core.services.*.\n\n## Consequences\n- Host configs set values here.\n- Modules read from here, never hardcode values.
