---
domain: 00
id: "NIXH-00-DOM-001"
title: "Domain 00 — Core Architecture"
type: adr
status: accepted
complexity: 3
reviewed: 2026-05-21
tags:
  - domain
  - 00
  - core
  - architecture
description: "Architectural decisions for the 00-core domain."
provides:
  - my.core.*
requires: []
links:
  adr: docs/adr/ADR-00-core.md
  guide: docs/guides/00-core.md
---

# ADR-00: Domain Core Architecture

> Foundational decisions governing the entire NixOS configuration — master toggles, registry, tuning, hardware, boot, security primitives, and shared libraries.

---

## Context

Domain 00 is the foundation every other domain depends on. It establishes the dendritic pattern (flake-parts + den), the single source of truth (configs.nix + registry.nix), hardware abstraction, boot safety, encryption primitives, and the `mkService` factory that all service domains use.

---

## Decisions

### 00-00: Principles & Defaults
**Decision:** Master toggle `my.core.principles.enable` controls all core modules; `bastelmodus` defaults to false (strict mode). The system follows the dendritic pattern — auto-import via `import-tree` over `flake-parts`. No `specialArgs` needed — all modules share the global config scope.
**Rationale:** Single toggle for blast-radius control. Bastelmodus enables safe experimentation without breaking production. Dendritic auto-import eliminates manual registry maintenance.
**Alternatives considered:** Manual import lists (rejected — brittle at scale), specialArgs tunneling (rejected — error-prone in large setups).

### 00-01: Configs & Registry (SSoT)
**Decision:** `configs.nix` is the master Single Source of Truth for identity, hardware specs, network config, and service toggles. `registry.nix` holds feature flags. All modules read from `config.my.core.*`.
**Rationale:** Centralized definitions prevent scattered defaults and configuration drift.
**Alternatives considered:** Distributed defaults per module (rejected — causes conflicts and drift).

### 00-02: Nix Tuning
**Decision:** Weekly Nix store GC, `auto-optimise-store`, flakes enabled by default. `allowUnfree = false` with `allowedRequisites = all` to enforce binary-only builds and prevent supply-chain attacks. `nix eval` used for module metadata extraction instead of Python regex.
**Rationale:** Binary-only policy ensures reproducible, auditable builds. Automated GC prevents store bloat. `nix eval` provides clean JSON without phantom IDs.
**Alternatives considered:** `allowUnfree = true` (rejected — unnecessary attack surface), Python regex parsing (rejected — fragile).

### 00-03: Hardware Profile
**Decision:** CPU microcode and GPU drivers are conditional on `cpuType` and `intelGpu` options. Fujitsu Q958 (Intel i3-9100, 16GB RAM, Intel UHD 630 QuickSync) is the reference hardware. ABC tiering: NVMe (Tier A), SSD in WLAN slot (Tier B), HDDs (Tier C).
**Rationale:** Hardware-agnostic modules with specific overrides per host. QuickSync transcoding requires `intel-compute-runtime`.
**Alternatives considered:** Hardcoded hardware config (rejected — not portable).

### 00-04: Boot Safeguards
**Decision:** Default 5 boot generations, memtest enabled. `configurationLimit = 10` with automatic drift detection prevents /boot overflow. Auto GC trigger on old generation cleanup.
**Rationale:** Prevents boot failures from partition exhaustion — critical for headless servers.
**Alternatives considered:** Unlimited generations (rejected — boot partition fills up).

### 00-05: TPM2 Sealing
**Decision:** TPM2 support is optional and off by default. Used for SOPS secret sealing. FIDO2 with client-PIN enforcement (`fido2-with-client-pin=yes`) for physical token + PIN requirement. `systemd-cryptenroll` integrates TPM2 and FIDO2 for LUKS.
**Rationale:** Multi-factor disk encryption (TPM2 + FIDO2) provides strong security without sacrificing usability. Off by default to avoid locking out systems without TPM.
**Alternatives considered:** Clevis-only (rejected — Clevis is for Tang/NBDE only).

### 00-06: ZRAM Swap
**Decision:** ZRAM with zstd compression, sized at 25% of RAM, enabled by default.
**Rationale:** Compressed RAM swap is 3-5× faster than disk swap and reduces SSD write amplification — critical on systems with limited RAM (16GB).
**Alternatives considered:** Disk swap file (rejected — slower, SSD wear).

### 00-07: Locale & System
**Decision:** Module provides empty defaults — host configuration must set locale, timezone, and keymap values.
**Rationale:** Locale is host-specific (server vs. laptop), so modules only define the interface.
**Alternatives considered:** Module-level defaults (rejected — wrong for multi-host setups).

### 00-08: Users & Groups
**Decision:** Module defines user structure declaratively. Personal config (aliases, packages) goes to per-user home-manager configs under `users/<name>/`. Shared GID 169 for all media services.
**Rationale:** Separation of system-level user definitions from personal preferences. Shared media GID enables unified file access across services.
**Alternatives considered:** Imperative user management (rejected — not reproducible).

### 00-09: PostgreSQL
**Decision:** Single shared PostgreSQL instance, enabled via single toggle. Placed in 00-core because it forms the database cluster foundation for dependent web apps (miniflux, paperless, n8n).
**Rationale:** Shared instance reduces resource usage and simplifies backup strategy. Core-level placement reflects its infrastructural role.
**Alternatives considered:** Per-service databases (rejected — resource waste, complex backups).

### 00-10: Shell Premium
**Decision:** Enhanced shell environment with fastfetch MOTD (LAN IP, dashboard URL, hardware info), service checker script (✅/❌ output), alias suite (nixos-rebuild, git, ls, cat), and tool upgrades (eza, bat, duf, dust). All tools from Nixpkgs.
**Rationale:** Immediate system orientation on login is critical for headless homelab operations. Consistent tooling reduces cognitive load.
**Alternatives considered:** Default bash (rejected — insufficient for rapid ops).

### 00-11: Symbiosis — Hardware Abstraction
**Decision:** Auto-detect CPU vendor (Intel/AMD) for microcode updates. RAM warning if < 4GB. Hardware profile age check (> 30 days). CLI tool `nixhome-detect-hw` for hardware detection.
**Rationale:** Eliminates manual CPU vendor config. Early warnings prevent deployment on underpowered hardware.
**Alternatives considered:** Manual CPU config (rejected — error-prone).

### 00-12: Service Helpers Library
**Decision:** `mkService` factory pattern — single function call generates systemd service with security hardening, Caddy reverse proxy vhost, SSO authentication via pocket-id import, and port management via central registry.
**Rationale:** Eliminates boilerplate across all service domains. Ensures consistent hardening. Makes adding new services a one-liner.
**Alternatives considered:** Manual service definitions (rejected — boilerplate, inconsistency risk).

### 00-13: Config Merger
**Decision:** Nix defaults (identity, IPs, domain) merged with runtime JSON overrides at `/var/lib/nixhome/user-config.json` via `jq` deep merge. Result written to `/run/nixhome/config.json` (tmpfs, no persistence). `nixhome-apply` script merges and reloads services.
**Rationale:** Runtime configuration changes without NixOS rebuild. User-friendly JSON for non-Nix users. Nix defaults ensure sane baseline.
**Alternatives considered:** Pure NixOS config (rejected — requires rebuild for every change).

### 00-14: UID Registry
**Decision:** Central UID/GID registry for all services. Prevents ID collisions across domains.
**Rationale:** Consistent service identities across hosts. Eliminates permission conflicts from duplicate UIDs.
**Alternatives considered:** Auto-assigned UIDs (rejected — non-deterministic across rebuilds).

### 00-15: Services Spec
**Decision:** Declarative service specification with port registry, health checks, and dependency graphs.
**Rationale:** Single source of truth for all service metadata. Enables automated documentation.
**Alternatives considered:** Scattered port definitions (rejected — conflicts, drift).

### 00-16: Boot Watchdog
**Decision:** Systemd watchdog timer for boot failure detection. Automatic rollback on boot hang.
**Rationale:** Critical for headless servers. Prevents permanent unreachability after bad config.
**Alternatives considered:** No watchdog (rejected — single point of failure).

### 00-17: Recovery USB
**Decision:** Recovery USB image generation with known-good config and rollback scripts.
**Rationale:** Physical recovery path for headless servers with failed boots.
**Alternatives considered:** Network-only recovery (rejected — useless if network stack broken).

### 00-18: Admin Triggers
**Decision:** Trigger-based admin actions (reboot, rollback, emergency mode) via systemd targets.
**Rationale:** Standardized emergency procedures. Scriptable admin actions.
**Alternatives considered:** Manual SSH commands (rejected — error-prone under stress).

### 00-19: User Preferences
**Decision:** Central `my.core.*` namespace for all user-configurable identity and preference settings. Covers identity (domain, timezone, locale, keyboard), user account (username, fullName, email, shell), appearance (cursor theme, icon theme, font family/size), and network (DNS servers, proxy settings).
**Rationale:** Single place for all user preferences. Replaces hardcoded values across modules. Enables easy customization without touching individual modules.
**Alternatives considered:** Scattered per-module options (rejected — inconsistent, hard to find).

---

## Consequences

### Positive
- Single master toggle for entire core layer
- Consistent service hardening via mkService factory
- Zero-touch boot on known hardware (TPM2), FIDO2 fallback for unknown
- No configuration drift — every decision is declarative
- Binary-only policy eliminates supply-chain risk

### Negative
- High interdependence — breaking core affects all domains
- Bastelmodus bypass can mask real issues if overused
- Config Merger creates two sources of truth (Nix + JSON)
- mkService abstraction hides complexity — harder to debug non-standard services

---

## Module Inventory

| Module | Purpose |
|--------|---------|
| 00-principles.nix | Master toggle, bastelmodus flag, dendritic pattern |
| 01-configs-registry.nix | SSoT for identity, hardware, network, ports, services |
| 01-lib-mkservice.nix | mkService factory for systemd + Caddy + SSO |
| 02-defaults.nix | Default settings for all modules |
| 02-nix-tuning.nix | GC, auto-optimise-store, binary-only policy |
| 03-hardware-profile.nix | CPU microcode, GPU drivers, conditional hardware |
| 03-ports.nix | Port registry for all services |
| 04-boot-safeguards.nix | Generation limit, memtest, boot overflow protection |
| 04-registry.nix | Feature flags and service toggles |
| 05-system-stability.nix | System stability monitoring |
| 05-tpm2.nix | TPM2 sealing, FIDO2 LUKS, SOPS integration |
| 06-config-merger.nix | Nix defaults + runtime JSON merge |
| 06-zram-swap.nix | Compressed swap (zstd, 25% RAM) |
| 07-locale-system.nix | Interface for locale, timezone, keymap |
| 07-shell-premium.nix | Enhanced shell: fastfetch, aliases, tool upgrades |
| 08-tty-info.nix | TTY information display |
| 08-users-shell.nix | Declarative users, shared media GID 169 |
| 09-backup.nix | Backup configuration |
| 09-postgresql.nix | Shared PostgreSQL instance |
| 10-nix-tuning.nix | Nix tuning (duplicate) |
| 10-shell-premium.nix | Shell premium (duplicate) |
| 11-symbiosis.nix | Hardware auto-detection, microcode, RAM warnings |
| 12-lib-helpers.nix | recursiveImportDir, mkService factory |
| 13-config-merger.nix | Nix defaults + runtime JSON merge |
| 14-uid-registry.nix | Central UID/GID registry for all services |
| 15-services-spec.nix | Declarative service specification with port registry |
| 16-boot-watchdog.nix | Systemd watchdog for boot failure detection |
| 17-recovery-usb.nix | Recovery USB image generation |
| 18-admin-triggers.nix | Trigger-based admin actions |
| 19-user-preferences.nix | Central `my.core.*` namespace: identity, user, appearance, network |

---

## Cross-Domain Dependencies

- Depends on: None (foundation layer)
- Used by: All other domains (10–90)
