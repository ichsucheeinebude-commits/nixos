---
domain: 00
id: "NIXH-00-COR-007"
title: "ZRAM Swap"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,zram,swap]
description: "ZRAM compressed swap."
path: "docs/adr/ADR-06-zram-swap.md"
links:
  module: "modules/placeholder.nix"
---

# ADR: ZRAM Swap

## Context\nZRAM provides fast, compressed swap in RAM.\n## Decision\nEnabled by default, zstd algorithm, 25% of RAM.\n## Consequences\nBetter memory management without disk swap penalty.
