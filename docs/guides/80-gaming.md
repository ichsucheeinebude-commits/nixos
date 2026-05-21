---
domain: 80
id: "NIXH-80-DOM-001"
title: "Domain 80 — Gaming Guide"
type: guide
status: draft
complexity: 2
reviewed: 2026-05-21
tags:
  - domain
  - 80
  - gaming
  - operations
description: "Operational guide for the 80-gaming domain."
links:
  adr: ADR-80-gaming.md
  guide: 80-gaming.md
---

# 80-gaming: Domain Gaming Guide

> Operational procedures for AMP game server management and FHS sandbox.

---

## Prerequisites

- Domain 00 (core) deployed
- Domain 10 (network, firewall ports for game servers)
- Sufficient RAM and CPU for game server workloads

---

## Module Operations (ODR-sorted)

### 80-80: AMP Game Servers
**Enable:** `my.gaming.amp.enable = true;` FHS-sandboxed instance.
**Verify:** AMP web UI accessible. Game server instances show as running. `systemctl status amp` shows running.
**Troubleshooting:** AMP not starting — check FHS sandbox dependencies. Game server crashes — verify resource limits.

### 80-81: AMP FHS Sandbox
**Enable:** Automatically enabled with AMP. Provides dotnet-sdk and FHS paths (/srv/, etc.).
**Verify:** Inside FHS env: `ls /srv/` shows expected paths. `dotnet --version` shows SDK available.
**Troubleshooting:** FHS paths missing — check buildFHSEnv configuration. dotnet not found — verify SDK package in sandbox.

---

## Cross-Domain Interactions

- Depends on: Domain 00 (core), Domain 10 (network, firewall)
- Used by: None (leaf domain)
