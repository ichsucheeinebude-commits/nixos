---
domain: 90
id: "NIXH-90-DOM-001"
title: "Domain 90 — Policy Guide"
type: guide
status: draft
complexity: 2
reviewed: 2026-05-21
tags:
  - domain
  - 90
  - policy
  - operations
description: "Operational guide for the 90-policy domain."
links:
  adr: ADR-90-policy.md
  guide: 90-policy.md
---

# 90-policy: Domain Policy Guide

> Operational procedures for forbidden technology checks, architecture rules, deferred operations, security assertions, and binary-only build policy.

---

## Prerequisites

- Domain 00 (core) deployed
- Understanding of NixOS assertion system
- bastelmodus flag for development bypass

---

## Module Operations (ODR-sorted)

### 90-90: Forbidden Technology
**Enable:** Enabled by default. Assertions fire at build time if forbidden tech is detected.
**Verify:** `nixos-rebuild switch` fails if Docker, iptables, cron, etc. are enabled. Error message shows forbidden technology.
**Troubleshooting:** Legitimate need for forbidden tech — use bastelmodus or `lib.mkForce` with justification.

### 90-91: Architecture Rules
**Enable:** Enabled by default. Dendritic pattern assertions.
**Verify:** Build succeeds with proper dendritic structure. Architecture violations cause build failure.
**Troubleshooting:** Architecture violation — review module structure. Ensure auto-import via import-tree is working.

### 90-92: Deferred Storage Operations
**Enable:** `my.policy.deferredOps.enable = true;` Configure HDD sleep schedule.
**Verify:** `systemctl list-timers | grep deferred` shows schedule. Check logs for deferred operation execution.
**Troubleshooting:** Operations not deferred — check HDD sleep schedule config. Verify systemd timer is active.

### 90-93: Security Assertions
**Enable:** Enabled by default. `must` helper for assertion + message.
**Verify:** `nixos-rebuild switch` fails on security violations: SEC-NET-001 (firewall), SEC-NET-002 (NFTables), SEC-SSH-002 (root SSH).
**Troubleshooting:** Assertion failure — fix the underlying security issue. In bastelmodus, assertions are skipped (development only).

### 90-94: Binary-Only Build Policy
**Enable:** Enabled by default. `max-jobs = 0` assertion.
**Verify:** `nix build .#` fails if no binary in cache. `nix show-config | grep max-jobs` shows 0.
**Troubleshooting:** Build fails with no binary — wait for upstream cache update, or build on external machine and push to Cachix. Use `lib.mkForce` only with justification.

---

## Cross-Domain Interactions

- Depends on: Domain 00 (core)
- Used by: All domains (policy applies globally)
