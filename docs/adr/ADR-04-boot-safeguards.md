---
domain: 00
id: "NIXH-00-COR-005"
title: "Boot Safeguards"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,boot]
description: "Boot safeguards: generation limit and memtest."
path: "docs/adr/ADR-04-boot-safeguards.md"
links:
  module: "modules/placeholder.nix"
---

# ADR: Boot Safeguards

## Context\nUnlimited boot generations fill the ESP. Memtest is essential for hardware diagnostics.\n## Decision\nDefault limit of 5 generations; memtest enabled by default.\n## Consequences\nESP stays manageable; memtest always available.
