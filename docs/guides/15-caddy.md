---
domain: 10
id: "NIXH-10-NET-006"
title: "Caddy Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,caddy]
description: "Configure Caddy."
path: "docs/guides/GUIDE-15-caddy.md"
links:
  module: "modules/10-network/15-caddy.nix"
---

# Guide: Caddy Guide

Set email for ACME registration.


---

## KB Nuggets

### Caddyfile Mastery
```caddyfile
:443 {
  reverse_proxy /api/* localhost:8080
  reverse_proxy /* localhost:3000
  tls internal {
    on_demand
  }
}
```
Operations, API, Logging → guides/caddy/
### Orange vs Gray Cloud
**Orange (Proxied):** Vaultwarden, Paperless — schützt Heim-IP.
**Gray (DNS-only):** Jellyfin — Cloudflare Free hat Streaming-Limits.
