---
domain: 90
id: "NIXH-90-POL-001"
title: "Forbidden Technology"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
source: "architect-vision-v5"
tags: [policy,forbidden]
description: "Build-time forbidden-tech assertions."
path: "docs/adr/ADR-90-forbidden-tech.md"
links:
  module: "modules/90-policy/90-forbidden-tech.nix"
---

# ADR: Forbidden Technology

## Decision
Docker, Tailscale, cron, iptables, lanzaboote, SFTPGo are forbidden.


---

## KB Nuggets

=== Native Services over Docker
Docker widerspricht dem NixOS-Prinzip. Native systemd-Services sind Pflicht. Supply-Chain-Sicherheit durch deklarativen Build.
=== Distribution Strategy v5
Vanilla-Boilerplate als Basis. Personalisierung nur via hosts/ und users/. Keine Impurities.
