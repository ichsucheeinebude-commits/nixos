---
domain: 00
id: "NIXH-00-COR-006"
title: "TPM2 Sealing"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,tpm2,security]
description: "TPM2-based SOPS secret sealing."
path: "docs/adr/ADR-05-tpm2.md"
links:
  module: "modules/placeholder.nix"
---

# ADR: TPM2 Sealing

## Context\nTPM2 can seal secrets to specific hardware state.\n## Decision\nOptional TPM2 support, off by default.\n## Consequences\nWhen enabled, SOPS can use TPM2 for hardware-bound secrets.
