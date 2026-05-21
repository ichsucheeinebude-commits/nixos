---
domain: 00
id: "NIXH-00-COR-010"
title: "PostgreSQL"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,postgresql]
description: "PostgreSQL as central database."
path: "docs/adr/ADR-09-postgresql.md"
links:
  module: "modules/placeholder.nix"
---

# ADR: PostgreSQL

## Context\nMany services need PostgreSQL.\n## Decision\nSingle toggle, shared instance.\n## Consequences\nServices declare ensureDatabases/ensureUsers in their own modules.
