---
domain: 60
id: "NIXH-60-PAP-001"
title: "Paperless-ngx — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [paperless, documents]
description: "Paperless-ngx module."
path: "root/guides/60-paperless.md"
links:
  adr: ADR-60-paperless.md
  guide: 60-paperless.md
  module: modules/60-apps/60-paperless.nix
---

# "Paperless-ngx"

**Domain:** 60-apps
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-60-PAP-001"

---

## Overview

This module provides "paperless-ngx" functionality for the NixOS system.
"Paperless-ngx module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."paperless-ngx".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "paperless-ngx"

# Check config was applied
nixos-option my.services."paperless-ngx".enable

# Check logs
journalctl -u "paperless-ngx" -f --no-pager
```

## Known Failure Modes

| Symptom | Cause | Fix |
|---|---|---|
| Service not starting | Database not initialized | Check PostgreSQL status and SOPS secrets |
| SSO login fails | Caddy forward auth misconfigured | Verify Caddy vhost and Pocket-ID |
| Data loss after reboot | StateDir not persistent | Add to my.persistence.directories |

## Dependencies

- **Requires:** `00-principles.nix`, `01-configs-registry.nix` (and others per NIXMETA `requires`)
- **Required by:** Higher-domain modules that consume this service

## Maintenance

- **Log location:** `journalctl -u "paperless-ngx" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
