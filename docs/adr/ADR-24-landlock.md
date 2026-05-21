---
domain: 20
id: "NIXH-20-SEC-004"
title: "Landlock Sandboxing"
type: adr
status: draft
complexity: 3
reviewed: 2026-05-21
source: "guides/GUIDE-Landlock-Isolation-Mastery.md"
tags: [security,landlock,sandboxing,isolation]
description: "Kernel-level filesystem isolation via Landlock LSM for individual service sandboxing."
path: "docs/adr/ADR-24-landlock.md"
links:
  module: "modules/20-security/24-landlock.nix"
---

# ADR: Landlock Sandboxing

## Context
Services that process untrusted input (n8n automation, Python scripts, web apps) need filesystem isolation beyond systemd sandboxing. Traditional approaches (nsjail, AppArmor) are either heavyweight or require root-level policy configuration.

## Decision
- Use Landlock LSM for per-service filesystem isolation
- Landlock allows unprivileged processes to self-restrict filesystem access
- Combine with systemd sandboxing for defense-in-depth
- Enable audit mode first to detect blocked paths before enforcement

## Consequences
- **Positive:** Near-zero overhead, kernel-native (Linux 5.13+), unprivileged operation, protects against path traversal even if service is compromised
- **Negative:** Requires Linux 5.13+ (not an issue on current NixOS), initial configuration requires audit-mode tuning
- **Risk:** Low — Landlock is a stable kernel feature since 5.13
