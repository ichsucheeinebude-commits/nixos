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
  module: "modules/00-core/09-postgresql.nix"
---

# ADR: PostgreSQL

## Decision
Single toggle, shared instance.


---

## KB Nuggets

### PostgreSQL als fundamentale Infrastruktur
Liegt in 20-server (nicht 30-services) weil es Datenbank-Cluster für abhängige Web-Apps (miniflux, paperless, n8n) bildet.
