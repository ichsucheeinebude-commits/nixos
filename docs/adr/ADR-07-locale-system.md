---
domain: 00
id: "NIXH-00-COR-008"
title: "Locale & System"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,locale]
description: "System locale, timezone, keymap."
path: "docs/adr/ADR-07-locale-system.md"
links:
  module: "modules/placeholder.nix"
---

# ADR: Locale & System

## Context\nLocales and timezone must be configurable per host.\n## Decision\nAll locale options live in my.core.locale.\n## Consequences\nEmpty defaults mean no locale is forced.
