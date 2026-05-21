---
domain: 10
id: "NIXH-10-NET-013"
title: "Landing Zone UI Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags:
  - network
  - landing-page
description: "Static landing page with rescue fallback."
provides:
  - my.network.landingZone
requires:
  - my.network.caddy
links:
  adr: ADR-23-landing-zone-ui.md
  guide: 23-landing-zone-ui.md
  module: modules/10-network/23-landing-zone-ui.nix
---

# 23-landing-zone-ui: Landing Page

> Central entry point for all homelab services.

---

## How It Works

Static HTML page served via Caddy as the default virtual host. Lists all services with links and rescue instructions.

---

## Enable

```nix
my.network.landingZone.enable = true;
```

---

## Verify

```bash
curl http://localhost/
```
