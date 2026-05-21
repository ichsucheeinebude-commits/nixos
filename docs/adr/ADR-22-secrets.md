---
domain: 20
id: "NIXH-20-SEC-003"
title: "Secrets Management"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [security,sops]
description: "SOPS-based secrets."
path: "docs/adr/ADR-22-secrets.md"
links:
  module: "modules/20-security/22-secrets.nix"
---

# ADR: Secrets Management

## Decision
Age encryption, declarative secrets via sops-nix.


---

## KB Nuggets

### SOPS > git-crypt
sops-nix überlegen: Age-Keys (nicht GPG), native NixOS-Integration, YAML/JSON/ENV Support, automatische Template-Generierung.
