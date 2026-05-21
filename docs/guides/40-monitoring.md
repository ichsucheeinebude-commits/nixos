---
domain: 40
id: "NIXH-40-DOM-001"
title: "Domain 40 — Monitoring Guide"
type: guide
status: draft
complexity: 2
reviewed: 2026-05-21
tags:
  - domain
  - 40
  - monitoring
  - operations
description: "Operational guide for the 40-monitoring domain."
links:
  adr: ADR-40-monitoring.md
  guide: 40-monitoring.md
---

# 40-monitoring: Domain Monitoring Guide

> Operational procedures for health checks, telemetry, notifications, drive monitoring, log aggregation, and uptime dashboards.

---

## Prerequisites

- Domain 00 (core) deployed
- Domain 10 (network, Caddy) for reverse proxy
- Domain 40-42 (ntfy) active for notifications

---

## Module Operations (ODR-sorted)

### 40-40: Gatus Health Dashboard
**Enable:** `my.monitoring.gatus.enable = true;` Define endpoints in config.
**Verify:** Gatus web UI accessible. `curl http://localhost:<port>/api/v1/endpoints` shows endpoint status.
**Troubleshooting:** Endpoint showing down — verify service is running and accessible. Check Gatus config for correct URL.

### 40-41: Netdata Telemetry
**Enable:** `my.monitoring.netdata.enable = true;`
**Verify:** Netdata web UI at configured port. `systemctl status netdata` shows running.
**Troubleshooting:** High disk usage — check dbengine retention settings. Socket access only — verify bind address.

### 40-42: ntfy-sh
**Enable:** `my.monitoring.ntfy.enable = true;`
**Verify:** `curl http://localhost:<port>/v1/health` returns 200. Send test: `curl -d "test" http://localhost:<port>/test-topic`.
**Troubleshooting:** Notifications not received — check client subscription. Verify topic permissions.

### 40-43: Scrutiny SMART
**Enable:** `my.monitoring.scrutiny.enable = true;`
**Verify:** Scrutiny web UI shows drive health. `smartctl -a /dev/sdX` shows raw SMART data.
**Troubleshooting:** Drive not detected — check device permissions. SMART not supported — some USB enclosures don't pass through SMART.

### 40-44: Vector Log Aggregator
**Enable:** `my.monitoring.vector.enable = true;` Configure sources (journald) and sinks (file output).
**Verify:** `systemctl status vector`. Check output files for log entries. `vector vtop` shows real-time pipeline.
**Troubleshooting:** No logs in output — check source configuration. Verify journald access permissions.

### 40-45: Uptime Kuma
**Enable:** `my.monitoring.uptimeKuma.enable = true;`
**Verify:** Uptime Kuma web UI accessible. Monitors show green/red status.
**Troubleshooting:** False alerts — check monitor interval and timeout. Database corruption — restore from backup.

---

## Cross-Domain Interactions

- Depends on: Domain 00 (core), Domain 10 (network, Caddy)
- Used by: All service domains (health monitoring, alerting)
