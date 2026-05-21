---
domain: 20
id: "NIXH-20-SEC-003"
title: "Secrets Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [security,sops]
description: "Configure SOPS secrets."
path: "docs/guides/GUIDE-22-secrets.md"
links:
  module: "modules/20-security/22-secrets.nix"
---

# Guide: Secrets Guide

Requires sops-nix and age key setup.


---

## KB Nuggets

### SOPS Setup
Age-Key in `sops.age.sshKeyPaths`. Secrets in `secrets/*.sops.yaml`. Templates automatisch in `/run/secrets/`.
### Boot-Timing: SOPS nach SSH
SOPS-Entschlüsselung braucht SSH-Host-Key. Secret-Ingest erfolgt NACH sshd-Start in der Boot-Reihenfolge.
