# ADR-13: Config Merger

**Status:** Accepted  
**Date:** 2026-05-21  
**Domain:** 00-core  
**Module:** `13-config-merger.nix`

## Context

NixOS configurations are declarative and require a rebuild for changes. Runtime services like Caddy or Pocket-ID can read dynamic configurations from JSON files that can be updated without a rebuild.

## Decision

Implement **Config Merger Pattern**:

1. **Nix Defaults** — Identity, IPs, domain from NixOS configuration.
2. **User JSON Overrides** — `/var/lib/nixhome/user-config.json` for runtime adjustments.
3. **jq Deep Merge** — User overrides are merged with Nix defaults (jq `*` operator).
4. **Run-Time Output** — Result in `/run/nixhome/config.json` (tmpfs, no persistence).
5. **Reload Service** — `nixhome-apply` script merges and reloads services.

## Consequences

### Positive
- Runtime configuration changes without NixOS rebuild
- User-friendly JSON overrides for non-Nix users
- Nix defaults ensure sane baseline

### Negative
- Two sources of truth (Nix + JSON) — potential confusion
- JSON overrides lost on reboot (tmpfs storage)
- Requires jq dependency

## SRE Standards

- Merge order: Nix Defaults * User Overrides (overrides win)
- Output in /run (tmpfs) — no persistence across reboots
- Service reload only if active (systemctl is-active check)
- User config created with 0644 (readable by services)
