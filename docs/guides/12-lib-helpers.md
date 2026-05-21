---
domain: 00
id: "NIXH-00-COR-040"
title: "Service Helpers Library Guide"
type: guide
status: draft
complexity: 3
reviewed: 2026-05-21
tags:
  - core
  - library
  - factory
description: "Using mkService factory for consistent service definitions."
provides:
  - my.lib.mkService
requires:
  - my.network.dnsMap
  - my.network.caddy
links:
  adr: ADR-12-lib-helpers.md
  guide: 12-lib-helpers.md
  module: modules/00-core/12-lib-helpers.nix
---

# 12-lib-helpers: mkService Factory

> One-call service definition with hardening, reverse proxy, and SSO.

---

## How It Works

`mkService` takes a service definition and generates:
1. Systemd service with security hardening
2. Caddy virtual host with reverse proxy
3. SSO auth via pocket-id

---

## Usage

```nix
my.lib.mkService {
  name = "myservice";
  port = 8080;
  exec = "${pkgs.myservice}/bin/myservice";
}
```

---

## Verification

```bash
systemctl status myservice
curl -I http://myservice.${domain}
```
