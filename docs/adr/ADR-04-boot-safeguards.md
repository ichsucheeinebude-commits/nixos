---
domain: 00
id: "NIXH-00-COR-005"
title: "Boot Safeguards"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,boot]
description: "Boot generation limit and memtest."
path: "docs/adr/ADR-04-boot-safeguards.md"
links:
  module: "modules/00-core/04-boot-safeguards.nix"
---

# ADR: Boot Safeguards

## Decision
Default 5 generations, memtest enabled.


---

## KB Nuggets

### Boot-Overflow Schutz
/boot-Partition wird vor volllaufen geschützt durch automatische GC-Trigger und alte Generation Cleanup.
### EFI Cleanup
`configurationLimit = 10` + automatische Drift-Erkennung verhindert Boot-Failures nach vielen Rebuilds.
