---
domain: 00
id: "NIXH-00-COR-009"
title: "Users & Groups"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,users]
description: "Declarative user definitions (no aliases)."
path: "docs/adr/ADR-08-users-shell.md"
links:
  module: "modules/placeholder.nix"
---

# ADR: Users & Groups

## Context\nUsers need to be defined in modules, but aliases are personal.\n## Decision\nModule defines user structure; aliases go to users/ home-manager.\n## Consequences\nClean separation between system users and personal settings.
