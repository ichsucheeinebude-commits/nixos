---
domain: 40
id: "NIXH-40-MON-001"
title: "Gatus Health Dashboard"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
source: "claude-cloudflare-log-b99bb6b3"
tags: [monitoring,gatus]
description: "Gatus health monitoring."
path: "docs/adr/ADR-40-gatus.md"
links:
  module: "modules/40-monitoring/40-gatus.nix"
---

# ADR: Gatus Health Dashboard

## Decision
Declarative endpoint monitoring with ntfy alerts.


---

## KB Nuggets

=== Monitoring Hub: Gatus als Watchtower
Gatus überwacht alle Services via HTTP/TCP/ICMP. Alerting via Ntfy. Dashboard über Caddy.
