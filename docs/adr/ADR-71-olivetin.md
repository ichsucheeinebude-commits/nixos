# ADR-71: OliveTin Web Control Panel

**Status:** Accepted  
**Date:** 2026-05-21  
**Domain:** 60-apps  
**Module:** `71-olivetin.nix`

## Context

System administration via CLI is efficient, but not accessible to all team members. OliveTin provides a web UI with predefined, securely pinned shell commands.

## Decision

Implement **OliveTin Pattern**:

1. **Wake-on-Access** — Socket Activation: service starts only on first request.
2. **Command Pinning** — Only explicitly defined commands are executable.
3. **Sudo Rules** — Minimal required sudo rights for the olivetin user.
4. **Pre-configured Actions** — System Update, Secret Creation, Certificate Generation.

## Consequences

### Positive
- Web-based system administration
- Socket activation saves resources
- Command pinning prevents arbitrary execution

### Negative
- Additional attack surface (web UI)
- Sudo rules require careful auditing
- Must maintain action definitions

## SRE Standards

- Socket-Activation: wantedBy = sockets.target, service wantedBy = lib.mkForce []
- Sudo only for nixos-rebuild and defined scripts (not ALL)
- tmpfiles rule for certificate landing zone
