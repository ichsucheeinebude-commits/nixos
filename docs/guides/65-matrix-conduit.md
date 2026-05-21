---
domain: 60
id: "NIXH-60-MTX-001"
title: "Matrix Conduit — Operational Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [matrix, chat]
description: "Matrix Conduit module."
path: "root/guides/65-matrix-conduit.md"
links:
  adr: ADR-65-matrix-conduit.md
  guide: 65-matrix-conduit.md
  module: modules/60-apps/65-matrix-conduit.nix
---

# "Matrix Conduit"

**Domain:** 60-apps
**Status:** Draft
**Complexity:** 1/5
**ID:** "NIXH-60-MTX-001"

---

## Overview

This module provides "matrix conduit" functionality for the NixOS system.
"Matrix Conduit module."
It integrates with the SSoT configs registry for identity and network settings.

## Configuration

```nix
# Enable the service in your host configuration
my.services."matrix-conduit".enable = true;
```

Configuration is driven by `my.configs` (SSoT) and `my.ports` for port assignments.
Secrets are managed via SOPS and referenced through the secrets module.

## Verification

```bash
# Is the service running?
systemctl status "matrix-conduit"

# Check config was applied
nixos-option my.services."matrix-conduit".enable

# Check logs
journalctl -u "matrix-conduit" -f --no-pager
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

- **Log location:** `journalctl -u "matrix-conduit" -f`
- **Config reload:** `sudo nixos-rebuild switch`
- **Review cycle:** Module reviewed every release cycle
