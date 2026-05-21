---
domain: 00
id: "NIXH-00-COR-004"
title: "Hardware Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,hardware]
description: "Configure hardware."
path: "docs/guides/GUIDE-03-hardware-profile.md"
links:
  module: "modules/00-core/03-hardware-profile.nix"
---

# Guide: Hardware Guide

```nix
my.core.hardware.cpuType = "intel";
my.core.hardware.intelGpu = true;
```


---

## KB Nuggets

### Kernel-Surgical Diet
Blackliste unnötige Module (Bluetooth, WiFi, Sound wenn Headless). `systemd-analyze security` Ziel: < 4.0.
### A+E Key Limitation
WLAN-Slot = nur 2 PCIe Lanes oder SATA. Keine schnelle NVMe hier — perfekt für Download-Cache (Tier B).
