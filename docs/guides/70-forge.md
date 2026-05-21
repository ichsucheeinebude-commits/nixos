---
domain: 70
id: "NIXH-70-DOM-001"
title: "Domain 70 — Forge Guide"
type: guide
status: draft
complexity: 2
reviewed: 2026-05-21
tags:
  - domain
  - 70
  - forge
  - operations
description: "Operational guide for the 70-forge domain."
links:
  adr: ADR-70-forge.md
  guide: 70-forge.md
---

# 70-forge: Domain Forge Guide

> Operational procedures for Forgejo (Git), Semaphore (Ansible UI), and Cockpit (system admin).

---

## Prerequisites

- Domain 00 (core) deployed
- Domain 10 (network, Caddy) for reverse proxy
- Domain 20 (security, secrets) configured

---

## Module Operations (ODR-sorted)

### 70-70: Forgejo
**Enable:** `my.forge.forgejo.enable = true;` SQLite backend. Disable public registration.
**Verify:** Forgejo web UI accessible. Create test repository. `systemctl status forgejo` shows running.
**Troubleshooting:** Git push fails — check SSH key configuration. Database errors — verify SQLite file permissions.

### 70-71: Semaphore
**Enable:** `my.forge.semaphore.enable = true;` PostgreSQL backend. (Implementation TBD)
**Verify:** Semaphore web UI accessible (when implemented). Test playbook execution.
**Troubleshooting:** Service not starting — implementation may be incomplete. Check module status.

### 70-72: Cockpit
**Enable:** `my.forge.cockpit.enable = true;`
**Verify:** Cockpit web UI at port 9090. `systemctl status cockpit.socket` shows socket active.
**Troubleshooting:** Cannot login — verify PAM configuration. Socket not activating — check firewall rules for port 9090.

---

## Cross-Domain Interactions

- Depends on: Domain 00 (core), Domain 10 (network, Caddy), Domain 20 (security)
- Used by: Domain 90 (policy references)
