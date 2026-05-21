---
domain: 20
id: "NIXH-20-SEC-004"
title: "Secrets Schema"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [security,sops,schema]
description: "Declarative secrets schema."
path: "docs/adr/ADR-23-secrets-schema.md"
links:
  module: "modules/20-security/23-secrets-schema.nix"
---

# ADR: Secrets Schema

## Decision
Schema ensures required secrets are defined.


---

## KB Nuggets

### Secrets Schema
Jedes Secret hat einen definierten Typ (string, file, base64), Ziel-Pfad, und Berechtigungen (0600, root:service).
