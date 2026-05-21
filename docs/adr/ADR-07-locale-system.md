---
domain: 00
id: "NIXH-00-COR-008"
title: "Locale & System"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,locale]
description: "Locale, timezone, keymap."
path: "docs/adr/ADR-07-locale-system.md"
links:
  module: "modules/00-core/07-locale-system.nix"
---

# ADR: Locale & System

## Decision
Empty defaults — host must set values.


---

## KB Nuggets

### Locale in Hosts, nicht Modules
Zeitzone und Locale sind Host-spezifisch. Module definieren nur das Interface, hosts setzen die Werte.
