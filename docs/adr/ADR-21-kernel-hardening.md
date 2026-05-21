---
domain: 20
id: "NIXH-20-SEC-002"
title: "Kernel Hardening"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [security,kernel]
description: "Kernel module blacklist + sysctl."
path: "docs/adr/ADR-21-kernel-hardening.md"
links:
  module: "modules/20-security/21-kernel-hardening.nix"
---

# ADR: Kernel Hardening

## Decision
Blacklist unused hardware, enforce sysctl hardening.


---

## KB Nuggets

### Kernel-Surgical Diet
Blackliste unnötige Module für Headless-Server. `systemd-analyze security` Ziel: < 4.0.
