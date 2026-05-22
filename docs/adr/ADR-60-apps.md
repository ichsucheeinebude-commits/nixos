---
domain: 60
id: "NIXH-60-DOM-001"
title: "Domain 60 — Apps Architecture"
type: adr
status: accepted
complexity: 3
reviewed: 2026-05-21
tags:
  - domain
  - 60
  - apps
  - architecture
description: "Architectural decisions for the 60-apps domain."
provides:
  - my.apps.*
requires:
  - my.core.*
  - my.network.*
links:
  adr: docs/adr/ADR-60-apps.md
  guide: docs/guides/60-apps.md
---

# ADR-60: Domain Apps Architecture

> Knowledge management, automation, identity, IoT, communication, AI, and file management: Paperless, n8n, Vaultwarden, Home Assistant, Readeck, Matrix, Miniflux, Linkding, Monica, Karakeep, Linkwarden, OliveTin, Open WebUI, Navidrome, ReadeBook, and Filestash.

---

## Context

Domain 60 is the catch-all for application services that don't fit into media, forge, or gaming. These are personal productivity, communication, and knowledge tools. Most use PostgreSQL as their database backend (shared instance from Domain 00). All are reverse-proxied via Caddy (Domain 10) with SSO protection via Pocket-ID.

---

## Decisions

### 60-60: Paperless-ngx
**Decision:** PostgreSQL-backed document management with OCR enabled. All settings via Nix — no manual configuration. Complete declarative control over all 68+ configuration variables.
**Rationale:** PostgreSQL provides better performance than SQLite for large document collections. Declarative config ensures reproducibility.
**Alternatives considered:** SQLite backend (rejected — performance at scale).

### 60-61: n8n Automation
**Decision:** PostgreSQL-backed workflow automation platform. OIDC authentication via Pocket-ID. Encryption key from SOPS secrets (never hardcoded).
**Rationale:** Self-hosted automation eliminates Zapier/Make dependency. SOPS-managed encryption key prevents credential leaks.
**Alternatives considered:** Hardcoded encryption key (rejected — security violation), cloud automation (rejected — external dependency).

### 60-62: Vaultwarden
**Decision:** Lightweight Bitwarden-compatible password vault. Rust-based. Socket-activated. SSO-protected. SQLite backend (sufficient for homelab scale).
**Rationale:** Vaultwarden is lighter than official Bitwarden server. Rust provides memory safety. SQLite is sufficient for small user count.
**Alternatives considered:** Official Bitwarden (rejected — too heavy), KeePass (rejected — no web access).

### 60-63: Home Assistant
**Decision:** Minimal option surface — config via HA UI. Native NixOS integration. Zigbee via Zigbee2MQTT (Domain 10).
**Rationale:** HA's complexity is best managed through its own UI. NixOS module handles deployment, UI handles configuration.
**Alternatives considered:** Declarative HA config (rejected — too complex, HA changes frequently).

### 60-64: Readeck
**Decision:** Self-hosted read-it-later service. DynamicUser sandbox. Bookmarks and archiving.
**Rationale:** Alternative to Pocket/Instapaper with full data sovereignty. DynamicUser provides automatic sandboxing.
**Alternatives considered:** Wallabag (rejected — heavier), Pocket (rejected — cloud dependency).

### 60-65: Matrix Conduit
**Decision:** Rust-based lightweight Matrix homeserver. Significantly lighter than Synapse. Perfect for homelab scale.
**Rationale:** Conduit uses minimal resources compared to Synapse. Rust provides memory safety and performance.
**Alternatives considered:** Synapse (rejected — too resource-heavy), Dendrite (rejected — less mature).

### 60-66: Miniflux RSS
**Decision:** Socket-activated RSS reader. Minimal config. PostgreSQL backend. Native NixOS integration.
**Rationale:** Miniflux is lightweight and focused. PostgreSQL integrates with shared instance. Socket activation saves resources.
**Alternatives considered:** Tiny Tiny RSS (rejected — heavier), FreshRSS (rejected — PHP dependency).

### 60-67: Linkding
**Decision:** SSO-protected bookmark manager. Lightweight alternative to Readeck for simple link storage.
**Rationale:** Simple bookmark management without archiving overhead. Complements Readeck for quick link storage.
**Alternatives considered:** Browser bookmarks (rejected — not shared, not backed up).

### 60-68: Monica CRM
**Decision:** PostgreSQL-backed personal CRM for relationship management. Self-hosted.
**Rationale:** Self-hosted CRM keeps personal data private. PostgreSQL integrates with shared instance.
**Alternatives considered:** Cloud CRM (rejected — privacy concern).

### 60-69: Karakeep
**Decision:** SSO-protected bookmark manager with AI tagging. Modern alternative to Linkding.
**Rationale:** AI tagging automates bookmark organization. Complements existing bookmark tools.
**Alternatives considered:** Manual tagging (rejected — tedious).

### 60-70: Linkwarden
**Decision:** Collaborative bookmark manager with automatic archiving. NixOS service with Caddy integration and SSO. DynamicUser sandboxing. strict systemd security (ProtectSystem=strict, ProtectHome=true, SystemCallFilter). OOMScoreAdjust=300 (can be killed under memory pressure).
**Rationale:** Automatic URL archiving creates a persistent snapshot archive. Collaborative features enable family sharing.
**Alternatives considered:** Browser bookmarks (rejected — not shared).

### 60-71: OliveTin
**Decision:** Web-based control panel with predefined shell commands. Socket activation (service starts only on first request). Command pinning — only explicitly defined commands are executable. Minimal sudo rules (nixos-rebuild and defined scripts only, not ALL). Pre-configured actions: system update, secret creation, certificate generation.
**Rationale:** Makes system administration accessible to non-CLI users. Command pinning prevents arbitrary execution. Socket activation saves resources.
**Alternatives considered:** Direct SSH access (rejected — not accessible to non-technical users), unrestricted sudo (rejected — security risk).

### 60-72: Open WebUI
**Decision:** NixOS-native web interface for Ollama LLMs. Automatic OLLAMA_API_BASE_URL integration. Privacy controls (SCARF_NO_ANALYTICS, DO_NOT_TRACK, ANONYMIZED_TELEMETRY). DynamicUser sandboxing. GPU access via SupplementaryGroups (render, video). OOMScoreAdjust=200.
**Rationale:** Ollama API is not user-friendly. Open WebUI provides chat interface and model management. Privacy controls prevent telemetry leakage.
**Alternatives considered:** Direct Ollama API (rejected — no UI), cloud LLMs (rejected — privacy, cost).

### 60-73: Navidrome
**Decision:** Music streaming server. Subsonic API compatible. Part of the media stack (Domain 50) but placed in apps for organizational clarity.
**Rationale:** Self-hosted music streaming. Subsonic API compatibility enables wide client support.
**Alternatives considered:** Funkwhale (rejected — heavier, less mature).

### 60-74: ReadeBook
**Decision:** Self-hosted audiobook reader. Complements Audiobookshelf for audiobook management.
**Rationale:** Dedicated audiobook reader with specialized features.
**Alternatives considered:** Audiobookshelf only (rejected — additional reader provides flexibility).

### 60-75: Filestash
**Decision:** Universal file management platform via Docker Hub (`pkgs.dockerTools.pullImage`). Providers: FTP, SFTP, S3, WebDAV, local. Audio/video transcoding and office document editing. SSO authentication support. Caddy reverse proxy at `files.<domain>`. theme.park integration.
**Rationale:** Single interface for all file backends. Docker required because filestash is not in nixpkgs (RFP #169231). SSO enables unified access control.
**Alternatives considered:** Native nixpkgs package (rejected — not available), Nextcloud (rejected — too heavy for file-only use).

---

## Consequences

### Positive
- All personal data self-hosted — no cloud dependency
- Consistent SSO protection across all apps
- Shared PostgreSQL reduces resource usage
- DynamicUser sandboxing provides automatic security for all services
- OliveTin enables non-technical family members to perform admin tasks

### Negative
- 13 services is a large attack surface (mitigated by SSO + firewall)
- PostgreSQL shared instance is a single point of failure for all apps
- Memory pressure under full load (mitigated by OOMScoreAdjust settings)
- Some apps overlap in functionality (Linkding vs Karakeep vs Linkwarden vs Readeck)

---

## Module Inventory

| Module | Purpose |
|--------|---------|
| 60-paperless.nix | Document management with OCR |
| 61-n8n.nix | Workflow automation platform |
| 62-vaultwarden.nix | Password vault (Bitwarden-compatible) |
| 63-home-assistant.nix | Smart home automation |
| 64-readeck.nix | Read-it-later service |
| 65-matrix-conduit.nix | Matrix homeserver (Rust-based) |
| 66-miniflux.nix | RSS feed reader |
| 67-linkding.nix | Bookmark manager |
| 68-monica.nix | Personal CRM |
| 69-karakeep.nix | AI-tagged bookmark manager |
| 70-linkwarden.nix | Collaborative bookmark archiver |
| 71-olivetin.nix | Web-based shell command panel |
| 72-open-webui.nix | LLM chat interface for Ollama |
| 73-navidrome.nix | Music streaming server (Subsonic API) |
| 74-readmeabook.nix | Audiobook reader |
| 75-filestash.nix | Universal file manager (S3/WebDAV/SFTP, Docker-based, SSO) |

---

## Cross-Domain Dependencies

- Depends on: Domain 00 (core, PostgreSQL), Domain 10 (network, Caddy, Pocket-ID), Domain 20 (security, secrets)
- Used by: Domain 40 (monitoring, health checks)
