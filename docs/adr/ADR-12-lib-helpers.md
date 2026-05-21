---
domain: 00
id: "NIXH-00-COR-040"
title: "Service Helpers Library"
type: adr
status: accepted
complexity: 3
reviewed: 2026-05-21
tags:
  - core
  - library
  - abstraction
  - factory
description: "mkService factory for one-call service definition with systemd hardening, Caddy reverse proxy, and SSO integration."
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

# ADR-12: Service Helpers Library

> Central `mkService` factory eliminates boilerplate for systemd services with hardening, reverse proxy, and SSO.

---

## Context

Each service needs: systemd definition, hardening, Caddy reverse proxy, SSO integration, port config. Writing this manually creates boilerplate and inconsistencies.

---

## Decision

**`mkService` Factory Pattern:**

Single function call generates:
1. Systemd service with security hardening (ProtectSystem, PrivateTmp, etc.)
2. Caddy virtual host with reverse proxy
3. SSO authentication via pocket-id import
4. Port management via central registry

---

## Consequences

**Positiv:** Consistent hardening across all services, less boilerplate, easier to add new services.
**Negativ:** Abstraction layer hides complexity — harder to debug non-standard services.
