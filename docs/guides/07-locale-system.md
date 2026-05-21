---
domain: 00
id: "NIXH-00-COR-008"
title: "Locale Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,locale]
description: "Configure locale."
path: "docs/guides/GUIDE-07-locale-system.md"
links:
  module: "modules/00-core/07-locale-system.nix"
---

# Guide: Locale Guide

```nix
my.core.locale.timezone = "Europe/Berlin";
my.core.locale.default = "de_DE.UTF-8";
my.core.locale.keymap = "de";
```


---

## KB Nuggets

### Auto-Locale Detection
IP-basierte Locale-Erkennung für Mobile-Hosts (Laptop). Server haben statische Locale in ihrer Host-Config.
