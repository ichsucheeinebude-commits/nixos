---
domain: 20
id: "NIXH-20-SEC-001"
title: "Fail2ban"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [security,fail2ban]
description: "Fail2ban with NFTables."
path: "docs/adr/ADR-20-fail2ban.md"
links:
  module: "modules/20-security/20-fail2ban.nix"
---

# ADR: Fail2ban

## Decision
NFTables backend, incremental banning, Caddy JSON filter.


---

## KB Nuggets

### Fail2ban gehört zu 00-core (OS-Sicherheit)
Brute-Force Protection ist OS-Level, nicht Service-Level. Jeder Service ohne Fail2ban ist ungeschützt.
