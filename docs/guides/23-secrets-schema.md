---
domain: 20
id: "NIXH-20-SEC-004"
title: "Secrets Schema Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [security,sops]
description: "Define secrets schema."
path: "docs/guides/GUIDE-23-secrets-schema.md"
links:
  module: "modules/20-security/23-secrets-schema.nix"
---

# Guide: Secrets Schema Guide

Use schema attribute to declare required secrets.


---

## KB Nuggets

### SOPS Template Spec
YAML-Schema das Secret-Typen, Pfade, und Permissions definiert. Wird von sops-nix automatisch zu systemd-tmpfiles übersetzt.
