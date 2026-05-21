---
domain: 00
id: "NIXH-00-COR-001"
title: "Principles & Defaults"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,principles]
description: "Defines global enable toggle and experimental bastelmodus flag."
path: "docs/adr/ADR-00-principles.md"
links:
  module: "modules/placeholder.nix"
---

# ADR: Principles & Defaults

## Context\n\nWe need a single master toggle to enable/disable all boilerplate core modules,\nand an experimental flag for sandboxed tinkering.\n\n## Decision\n\n- my.core.principles.enable controls whether all core modules are active.\n- my.core.principles.bastelmodus defaults to false. When false, strict architecture rules apply.\n\n## Consequences\n- When bastelmodus = true, forbidden-tech assertions are relaxed.\n- When bastelmodus = false, all policy assertions are enforced at build time.
