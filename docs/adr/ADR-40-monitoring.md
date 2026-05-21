---
domain: 40
id: "NIXH-40-DOM-001"
title: "Domain 40 — Monitoring Architecture"
type: adr
status: accepted
complexity: 3
reviewed: 2026-05-21
tags:
  - domain
  - 40
  - monitoring
  - architecture
description: "Architectural decisions for the 40-monitoring domain."
provides:
  - my.monitoring.*
requires:
  - my.core.*
  - my.network.*
links:
  adr: docs/adr/ADR-40-monitoring.md
  guide: docs/guides/40-monitoring.md
---

# ADR-40: Domain Monitoring Architecture

> Multi-layer observability: health checks (Gatus), real-time telemetry (Netdata), notifications (ntfy), drive health (Scrutiny), log aggregation (Vector), and uptime dashboard (Kuma).

---

## Context

Domain 40 provides complete observability for the homelab: service health monitoring, real-time system metrics, push notifications, SMART drive monitoring, centralized log aggregation, and a visual uptime dashboard. The notification backbone (ntfy) is shared across all monitoring tools.

---

## Decisions

### 40-40: Gatus Health Dashboard
**Decision:** Declarative endpoint monitoring via Gatus. HTTP/TCP/ICMP checks for all services. Alerting via ntfy. Dashboard served via Caddy.
**Rationale:** Gatus provides code-configurable health checks (declarative in NixOS). Single dashboard for all service health. ntfy integration enables push alerts.
**Alternatives considered:** Uptime Robot (rejected — external dependency), Prometheus + Alertmanager (rejected — too complex for homelab).

### 40-41: Netdata Telemetry
**Decision:** Real-time system monitoring with Netdata. Socket-only access. dbengine storage for efficient long-term retention.
**Rationale:** Netdata provides out-of-the-box dashboards with zero config. dbengine stores historical data efficiently. Socket-only access limits exposure.
**Alternatives considered:** Prometheus + Grafana (rejected — more setup, more resources).

### 40-42: ntfy-sh
**Decision:** Self-hosted notification server. Simple HTTP API. No account required. No cloud dependency.
**Rationale:** Self-hosted ntfy eliminates external notification dependency. Simple HTTP API makes integration trivial. No account friction.
**Alternatives considered:** Pushover (rejected — external service, account required), email alerts (rejected — delayed, cluttered inbox).

### 40-43: Scrutiny SMART
**Decision:** Scrutiny + smartd for drive health monitoring. Automatic SMART checks for all HDDs/SSDs. Alerts on deteriorating values.
**Rationale:** Early warning for drive failures prevents data loss. Scrutiny provides a visual dashboard. smartd handles low-level SMART polling.
**Alternatives considered:** smartd-only (rejected — no visual dashboard), hdparm scripts (rejected — manual, no alerting).

### 40-44: Vector Log Aggregator
**Decision:** Journald → file output pipeline via Vector. Filters, transforms, and routes logs from all services. Replacement for ELK stack.
**Rationale:** Vector is lightweight and declarative. Replaces heavy ELK stack. File output enables offline analysis.
**Alternatives considered:** ELK/EFK (rejected — too resource-heavy), fluentd (rejected — more complex config).

### 40-45: Uptime Kuma
**Decision:** Self-hosted uptime monitoring dashboard. Secondary monitor to Gatus for manual verification.
**Rationale:** Visual dashboard complements Gatus's API-driven approach. Useful for manual spot-checks and family-friendly status page.
**Alternatives considered:** Gatus only (rejected — no visual dashboard for non-technical users).

---

## Consequences

### Positive
- Complete observability: health, metrics, logs, drive status, notifications
- All tools self-hosted — no external monitoring dependency
- ntfy provides unified notification channel for all alerts
- Lightweight stack suitable for 16GB RAM system

### Negative
- 6 monitoring services consume resources (mitigated by selective enable)
- Netdata and Gatus overlap in functionality (Gatus = health, Netdata = metrics)
- Log aggregation to files only — no search UI (mitigated by grep/Vector transforms)

---

## Module Inventory

| Module | Purpose |
|--------|---------|
| 40-gatus.nix | Endpoint health monitoring, ntfy alerts |
| 41-netdata.nix | Real-time system telemetry |
| 42-ntfy.nix | Self-hosted push notifications |
| 43-scrutiny.nix | SMART drive health monitoring |
| 44-vector.nix | Log aggregation pipeline |
| 45-uptime-kuma.nix | Visual uptime dashboard |

---

## Cross-Domain Dependencies

- Depends on: Domain 00 (core), Domain 10 (network, Caddy)
- Used by: All service domains (health checks, notifications)
