---
domain: 60
id: "NIXH-60-APP-001"
title: "Paperless Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
source: "https://github.com/paperless-ngx/paperless-ngx, NixOS Manual"
tags: [apps,paperless]
description: "Configure Paperless."
path: "docs/guides/GUIDE-60-paperless.md"
links:
  module: "modules/60-apps/60-paperless.nix"
---

# Guide: Paperless Guide

```nix
my.apps.paperless.enable = true;
```


---

## KB Nuggets

=== Paperless Master-Config
OCR: Tesseract (de+en). Consumedir: /persist/paperless/consume. Media: Tier A. Export: Restic-Backup.
=== Paperless Master-Variable-List
Komplette Referenz aller 40+ Konfigurationsvariablen mit Defaults und Beschreibung.
