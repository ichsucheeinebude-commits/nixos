---
domain: 10
id: "NIXH-10-NET-013"
title: "Landing Zone UI"
type: adr
status: accepted
complexity: 1
reviewed: 2026-05-21
tags:
  - network
  - landing-page
  - static
description: "Static landing page served via Caddy with rescue fallback for homelab service overview."
provides:
  - my.network.landingZone
requires:
  - my.network.caddy
links:
  adr: ADR-23-landing-zone-ui.md
  guide: 23-landing-zone-ui.md
  module: modules/10-network/23-landing-zone-ui.nix
---

# ADR-23: Landing Zone UI

> Central landing page for homelab services with rescue fallback.

---

## Context

A homelab needs a central entry point — a landing page listing all available services and showing rescue options in emergencies.

---

## Decision

**Static HTML landing page via Caddy:**

1. Static HTML page listing all services with links.
2. Rescue fallback: SSH access info, recovery instructions.
3. Served via Caddy as the default virtual host.

---

## Consequences

**Positiv:** Single entry point for all services, no external dependencies.
**Negativ:** Manual maintenance when services are added/removed.
