---
domain: 40
id: "NIXH-40-MON-002"
title: "Netdata Telemetry"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [monitoring,netdata]
description: "Netdata real-time monitoring."
path: "docs/adr/ADR-41-netdata.md"
links:
  module: "modules/40-monitoring/41-netdata.nix"
---

# ADR: Netdata Telemetry

## Decision
Socket-only access, dbengine storage.


---

## KB Nuggets

=== System Monitoring & Telemetry
Netdata für Echtzeit-Metriken. InfluxDB für Langzeit-Speicherung. Grafana für Dashboards.
