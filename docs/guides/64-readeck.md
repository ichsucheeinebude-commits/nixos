---
domain: 60
id: "NIXH-60-APP-005"
title: "Readeck Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [apps,readeck]
description: "Configure Readeck."
path: "docs/guides/GUIDE-64-readeck.md"
links:
  module: "modules/60-apps/64-readeck.nix"
---

# Guide: Readeck Guide

```nix
my.apps.readeck.enable = true;
```


---

## KB Nuggets

=== Readeck Setup
SQLite-Backend. Export: Markdown + Original-HTML. Backup: Restic. OIDC-Auth.
