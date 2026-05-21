---
domain: 00
id: "NIXH-00-COR-006"
title: "TPM2 Sealing"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,tpm2,security]
description: "TPM2 for SOPS."
path: "docs/adr/ADR-05-tpm2.md"
links:
  module: "modules/00-core/05-tpm2.nix"
---

# ADR: TPM2 Sealing

## Decision
Optional, off by default.


---

## KB Nuggets

### TPM2 + FIDO2 Multi-Factor LUKS
`systemd-cryptenroll` integriert TPM2 und FIDO2 direkt. Clevis nur noch für Tang (Network Bound Disk Encryption).
### FIDO2 Client-PIN Enforcement
`fido2-with-client-pin=yes` erfordert physischen Touch + PIN am Token — nicht nur Plug-in.
