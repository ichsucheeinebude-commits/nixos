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
  module: "modules/00-core/06-zram-swap.nix"
---

# ADR: ZRAM Swap

## Decision
zstd, 25% of RAM, enabled by default.


---

## KB Nuggets

### ZRAM > Disk Swap
Compressed RAM swap ist 3-5× schneller als Disk-swap und reduziert SSD-Write- amplification.
