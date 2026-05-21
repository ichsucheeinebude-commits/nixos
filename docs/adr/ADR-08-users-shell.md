---
domain: 00
id: "NIXH-00-COR-009"
title: "Users & Groups"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,users]
description: "Declarative user definitions."
path: "docs/adr/ADR-08-users-shell.md"
links:
  module: "modules/00-core/08-users-shell.nix"
---

# ADR: Users & Groups

## Decision
Module defines user structure; aliases go to users/ home-manager.


---

## KB Nuggets

### Declarative User Management
Users werden in modules/ definiert, persönliche Config (Aliases, Pakete) in users/<name>/.
### GID 169 Media-Gruppe
Alle Media-Services teilen GID 169 für einheitliche Dateizugriffe über Tier A/B/C.
