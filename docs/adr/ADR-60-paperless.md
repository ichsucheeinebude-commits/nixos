---
domain: 60
id: "NIXH-60-APP-001"
title: "Paperless-ngx"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
source: "https://github.com/paperless-ngx/paperless-ngx, NixOS Manual"
tags: [apps,paperless]
description: "Paperless-ngx document management."
path: "docs/adr/ADR-60-paperless.md"
links:
  module: "modules/60-apps/60-paperless.nix"
---

# ADR: Paperless-ngx

## Decision
PostgreSQL-backed, OCR-enabled.


---

## KB Nuggets

=== Paperless-ngx: Totale deklarative Kontrolle
Alle Settings via Nix. Keine manuelle Konfiguration. PostgreSQL-Backend.
