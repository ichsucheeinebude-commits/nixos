---
domain: 00
id: "NIXH-00-COR-004"
title: "Hardware Profile"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,hardware]
description: "CPU microcode and GPU drivers."
path: "docs/adr/ADR-03-hardware-profile.md"
links:
  module: "modules/00-core/03-hardware-profile.nix"
---

# ADR: Hardware Profile

## Decision
Conditional on cpuType and intelGpu options.


---

## KB Nuggets

### Fujitsu <HOSTNAME> Hardware-Layout
Intel i3-9100, 16GB RAM, Intel UHD 630 (QuickSync). M.2 Main: Samsung PM961 500GB. M.2 WLAN: Apacer 250GB (SATA). 2× HDD (SATA + DVD-Caddy).
### Intel QuickSync Transcoding
`intel-compute-runtime` (nicht deprecated `intel-media-sdk`) für Hardware-Transcoding in Jellyfin.
