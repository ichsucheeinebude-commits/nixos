---
domain: 90
id: "NIXH-90-POL-001"
title: "Forbidden Tech Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [policy,forbidden]
description: "Forbidden technology policy."
path: "docs/guides/GUIDE-90-forbidden-tech.md"
links:
  module: "modules/90-policy/90-forbidden-tech.nix"
---

# Guide: Forbidden Tech Guide

Set bastelmodus = true to relax during experiments.


---

## KB Nuggets

=== Docker-Ban Rationale
1. Reproducibility: Docker-Images sind nicht deklarativ.
2. Security: Container haben Root-Zugriff auf den Host.
3. Maintainability: nixpkgs-Pakete sind besser integriert.
4. Storage: Overlay-FS Konflikte mit ZFS.
