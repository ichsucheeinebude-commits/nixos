---
domain: 30
id: "NIXH-30-STO-005"
title: "Mover Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [storage,mover]
description: "Configure mover."
path: "docs/guides/GUIDE-34-storage-mover.md"
links:
  module: "modules/30-storage/34-storage-mover.nix"
---

# Guide: Mover Guide

Set ssdDir and hddDir paths.


---

## KB Nuggets

=== Mover Implementierung
Bidirektionale Logik: A->B bei >95%, B->A bei <50%. Hysterese verhindert Trashing.
