---
domain: 00
id: "NIXH-00-COR-005"
title: "Boot Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,boot]
description: "Configure boot safeguards."
path: "docs/guides/GUIDE-04-boot-safeguards.md"
links:
  module: "modules/00-core/04-boot-safeguards.nix"
---

# Guide: Boot Guide

```nix
my.core.boot.configurationLimit = 10;
```


---

## KB Nuggets

### systemd-boot Safeguards
- Automatische alte-Generation-Bereinigung
- /boot-Overflow-Protection via pre-built Hook
- GC-Trigger nach jedem switch
