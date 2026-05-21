---
domain: 20
id: "NIXH-20-SEC-001"
title: "Fail2ban Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
source: "claude-cloudflare-log-b99bb6b3"
tags: [security,fail2ban]
description: "Configure Fail2ban."
path: "docs/guides/GUIDE-20-fail2ban.md"
links:
  module: "modules/20-security/20-fail2ban.nix"
---

# Guide: Fail2ban Guide

```nix
my.security.fail2ban.enable = true;
```


---

## KB Nuggets

### Fail2ban Master-Reference
Jail-Template für SSH, Caddy, Pocket-ID. Endpoint-Liste aller geschützten Services. Ban-Time: 1h, Max-Retry: 3.
### Fail2ban Endpoints
SSH (port 53844), Caddy (443), Pocket-ID (OIDC). Alle mit nftables Backend für native Integration.
