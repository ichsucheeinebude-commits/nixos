---
domain: 00
id: "NIXH-00-COR-004"
title: "Hardware Profile"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,hardware]
description: "Hardware-specific configuration for CPU microcode and GPU drivers."
path: "docs/adr/ADR-03-hardware-profile.md"
links:
  module: "modules/placeholder.nix"
---

# ADR: Hardware Profile

## Context\nDifferent CPUs need different microcode. Intel GPUs need VAAPI/QSV drivers.\n## Decision\nConditional activation based on my.core.hardware.cpuType and intelGpu.\n## Consequences\nZero config needed for generic hosts; specific hosts override.
