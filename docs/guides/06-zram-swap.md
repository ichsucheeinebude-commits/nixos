---
domain: 00
id: "NIXH-00-COR-007"
title: "ZRAM Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,zram]
description: "ZRAM configuration."
path: "docs/guides/GUIDE-06-zram-swap.md"
links:
  module: "modules/00-core/06-zram-swap.nix"
---

# Guide: ZRAM Guide

Defaults are production-ready.


---

## KB Nuggets

### ZRAM Konfiguration
`algorithm = "zstd"` + `memoryMax = 0.5 * ramGB`. Ideal für 16GB Q958 = 8GB ZRAM.
