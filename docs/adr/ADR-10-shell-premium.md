# ADR-10: Shell Premium — Advanced Shell Environment

**Status:** Accepted  
**Date:** 2026-05-21  
**Domain:** 00-core  
**Module:** `10-shell-premium.nix`

## Context

Standard NixOS shell login provides minimal information. For homelab operations, quick orientation is critical: which host, which services are running, which IPs are relevant.

## Decision

Implement a **Shell-Premium Pattern**:

1. **Fastfetch MOTD** — Custom JSON config with LAN IP, Dashboard URL, hardware info.
2. **Service Checker** — Bash script that checks critical services and outputs ✅/❌.
3. **Alias Suite** — Consistent shortcuts for nixos-rebuild, git, ls, cat, etc.
4. **Tool Upgrades** — eza instead of ls, bat instead of cat, duf instead of df, dust instead of du.

## Consequences

### Positive
- Immediate system orientation on login
- Consistent tool experience across all sessions
- Reduced cognitive load for common operations

### Negative
- Slight login delay (fastfetch execution)
- Additional system packages required
- SSH-specific behavior may differ from local

## SRE Standards

- All tools come from Nixpkgs (reproducible, no system dependencies)
- Fastfetch config is generated via `writeText` (declarative, versioned)
- Service checker is a `writeShellScriptBin` (no global PATH issues)
