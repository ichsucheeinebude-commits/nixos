---
domain: 70
id: "NIXH-70-FRG-001"
title: "Forgejo Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
source: "nixpkgs/pkgs/applications/version-management, forgejo docs, soft-serve"
tags: [forge,forgejo]
description: "Configure Forgejo."
path: "docs/guides/GUIDE-70-forgejo.md"
links:
  module: "modules/70-forge/70-forgejo.nix"
---

# Guide: Forgejo Guide

```nix
my.forge.forgejo.enable = true;
```


---

## KB Nuggets

=== Forgejo Setup
PostgreSQL-Backend. Git-SSH über eigenen Port. Actions: aktiv. Backup: täglich.
