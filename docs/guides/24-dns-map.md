---
domain: 10
id: "NIXH-10-NET-014"
title: "DNS Map Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags:
  - network
  - dns
  - mapping
description: "Central DNS subdomain mapping for all services."
provides:
  - my.network.dnsMap
requires:
  - my.core.identity
links:
  adr: ADR-24-dns-map.md
  guide: 24-dns-map.md
  module: modules/10-network/24-dns-map.nix
---

# 24-dns-map: DNS Mapping

> Central subdomain registry for all services.

---

## How It Works

Single attrset maps service names to subdomains. Used by Caddy, Blocky/AdGuard, and local hosts file.

---

## Configuration

```nix
my.network.dnsMap.services = {
  paperless = "docs";
  nextcloud = "cloud";
};
```

---

## Verify

```bash
getent hosts paperless.${domain}
```
