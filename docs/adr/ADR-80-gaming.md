---
domain: 80
id: "NIXH-80-DOM-001"
title: "Domain 80 — Gaming Architecture"
type: adr
status: accepted
complexity: 3
reviewed: 2026-05-21
tags:
  - domain
  - 80
  - gaming
  - architecture
description: "Architectural decisions for the 80-gaming domain."
provides:
  - my.gaming.*
requires:
  - my.core.*
  - my.network.*
links:
  adr: docs/adr/ADR-80-gaming.md
  guide: docs/guides/80-gaming.md
---

# ADR-80: Domain Gaming Architecture

> Game server management via AMP (Application Management Platform) in an FHS sandbox — native systemd services, no Docker.

---

## Context

Domain 80 provides game server hosting via AMP (Application Management Platform). Since AMP and many game servers expect a traditional FHS filesystem layout (/srv/, /etc/ standard paths), an FHS sandbox is required on NixOS. Docker is forbidden by policy, so native systemd services with FHS environment are the alternative.

---

## Decisions

### 80-80: AMP Game Servers
**Decision:** FHS-sandboxed AMP instance. Native systemd services instead of Docker. Application Management Platform for game server lifecycle management.
**Rationale:** AMP provides a unified interface for managing multiple game servers. FHS sandbox enables compatibility with game servers that expect standard Linux paths. Native systemd follows NixOS philosophy.
**Alternatives considered:** Docker containers (rejected — forbidden by policy), manual game server setup (rejected — AMP provides better management).

### 80-81: AMP FHS Sandbox
**Decision:** `buildFHSEnv` with dotnet-sdk and dependencies. Creates FHS user environment for AMP games that expect /srv/ and standard paths.
**Rationale:** Many game servers and AMP itself assume FHS compliance. buildFHSEnv provides a compatible environment without sacrificing NixOS reproducibility.
**Alternatives considered:** Docker FHS containers (rejected — forbidden by policy), patching game servers for NixOS paths (rejected — impractical).

---

## Consequences

### Positive
- Game servers manageable via unified AMP interface
- FHS sandbox enables compatibility with non-NixOS software
- Native systemd services are declarative and reproducible
- No Docker dependency

### Negative
- FHS sandbox adds complexity and resource overhead
- Game servers consume significant resources (RAM, CPU, network)
- FHS environment may have outdated dependencies compared to Nixpkgs

---

## Module Inventory

| Module | Purpose |
|--------|---------|
| 80-amp.nix | AMP game server panel |
| 81-amp-fhs.nix | FHS sandbox for AMP (dotnet-sdk, /srv/) |

---

## Cross-Domain Dependencies

- Depends on: Domain 00 (core), Domain 10 (network, firewall ports for game servers)
- Used by: None (leaf domain)
