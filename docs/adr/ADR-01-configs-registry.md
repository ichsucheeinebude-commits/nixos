---
domain: "00"
id: "NIXH-00-CRG-001"
title: "Configs & Registry (SSoT)"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [ssot,registry,configs]
description: "Single Source of Truth für Identity, Hardware, Paths, Network."
path: "docs/adr/ADR-01-configs-registry.md"
links:
  adr: "docs/adr/ADR-01-configs-registry.md"
  guide: "docs/guides/01-configs-registry.md"
  module: "modules/00-core/01-configs-registry.nix"
---

# ADR: Configs & Registry (SSoT)

## Context
Alle Host-Identitäten und Feature-Flags müssen zentral definiert sein.

## Decision
configs.nix als SSoT Master. registry.nix für Feature-Flags.

## Consequences
- Module lesen von config.my.core.*
- Keine verteilten Defaults
