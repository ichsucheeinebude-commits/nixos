---
domain: 00
id: "NIXH-00-COR-010"
title: "PostgreSQL Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,postgresql]
description: "Configure PostgreSQL."
path: "docs/guides/GUIDE-09-postgresql.md"
links:
  module: "modules/00-core/09-postgresql.nix"
---

# Guide: PostgreSQL Guide

```nix
my.core.postgresql.enable = true;
```


---

## KB Nuggets

### PostgreSQL Tuning
`shared_buffers = 256MB` + `effective_cache_size = 4GB` für 16GB q958. Auto-VACUUM für kleine Databases.
