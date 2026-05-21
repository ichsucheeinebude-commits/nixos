---
domain: 30
id: "NIXH-30-STO-003"
title: "Impermanence Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [storage,impermanence]
description: "Enable impermanence."
path: "docs/guides/GUIDE-32-impermanence.md"
links:
  module: "modules/30-storage/32-impermanence.nix"
---

# Guide: Impermanence Guide

```nix
my.storage.impermanence.enable = true;
```


---

## KB Nuggets

### Impermanence Setup
```nix
fileSystems."/".device = "none";
fileSystems."/".fsType = "tmpfs";
environment.persistence."/persist" = {
  directories = [ "/var/log" "/etc/ssh" ];
  files = [ "/etc/machine-id" ];
};
```
