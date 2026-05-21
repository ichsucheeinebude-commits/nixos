---
domain: 40
id: "NIXH-40-MON-003"
title: "ntfy-sh"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [monitoring,ntfy]
description: "Local ntfy-sh server."
path: "docs/adr/ADR-42-ntfy.md"
links:
  module: "modules/40-monitoring/42-ntfy.nix"
---

# ADR: ntfy-sh

## Decision
Self-hosted notification server.


---

## KB Nuggets

=== Ntfy > Pushover
Self-hosted, keine Account-Pflicht, einfache HTTP-API. Perfekt für Homelab-Alerting.
