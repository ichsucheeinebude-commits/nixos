---
domain: 10
id: "NIXH-10-NET-014"
title: "DNS Map"
type: adr
status: accepted
complexity: 1
reviewed: 2026-05-21
tags:
  - network
  - dns
  - subdomain
  - mapping
description: "Central DNS subdomain mapping for all services. Provides consistent hostname resolution."
provides:
  - my.network.dnsMap
requires:
  - my.core.identity
links:
  adr: ADR-24-dns-map.md
  guide: 24-dns-map.md
  module: modules/10-network/24-dns-map.nix
---

# ADR-24: DNS Map

> Central DNS subdomain mapping eliminates manual hostname management for all services.

---

## Context

Each service needs a hostname. Instead of managing these manually, a central DNS mapping generates subdomains automatically.

---

## Decision

**Central DNS Mapping Pattern:**

1. Single attrset maps service names to subdomains.
2. Used by Caddy for virtual hosts, by Blocky/AdGuard for DNS.
3. Automatic `networking.hosts` entries for local resolution.

---

## Consequences

**Positiv:** Single source of truth for all service hostnames.
**Negativ:** Changes require rebuild to propagate.
