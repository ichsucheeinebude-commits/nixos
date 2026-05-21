---
domain: 50
id: "NIXH-50-DOM-001"
title: "Domain 50 — Media Architecture"
type: adr
status: accepted
complexity: 3
reviewed: 2026-05-21
tags:
  - domain
  - 50
  - media
  - architecture
description: "Architectural decisions for the 50-media domain."
provides:
  - my.media.*
requires:
  - my.core.*
  - my.network.*
  - my.storage.*
links:
  adr: docs/adr/ADR-50-media.md
  guide: docs/guides/50-media.md
---

# ADR-50: Domain Media Architecture

> Complete media stack: library management, automated download (*arr suite), streaming (Jellyfin), discovery (Jellyseerr), and hardware-accelerated transcoding via Intel QuickSync.

---

## Context

Domain 50 implements a full self-hosted media solution on the Q958 (Intel i3-9100 with QuickSync). It covers media library paths, the *arr automation suite (Sonarr, Radarr, Prowlarr, Lidarr), download clients (SABnzbd), streaming servers (Jellyfin, Navidrome, Audiobookshelf), and media request management (Jellyseerr). All media services share GID 169 for unified file access across tiers.

---

## Decisions

### 50-50: Media Library
**Decision:** Centralized media paths with shared GID 169 for all media services. Read-only mounts for libraries. VPN confinement for download stack.
**Rationale:** Shared GID ensures consistent file permissions across all *arr services. Read-only mounts protect library integrity. VPN confinement prevents download leaks.
**Alternatives considered:** Per-service users (rejected — permission conflicts).

### 50-51: Arr Stack
**Decision:** Sonarr, Radarr, and Prowlarr enabled via single toggle. Shared database instance. API key auto-wiring.
**Rationale:** Single toggle reduces configuration complexity. Shared database reduces resource usage. Auto-wiring eliminates manual API key management.
**Alternatives considered:** Individual toggles (rejected — too many config points).

### 50-52: Download Stack
**Decision:** SABnzbd for NZB downloads. WireGuard namespace confinement — no leak possible.
**Rationale:** NZB is faster and more reliable than torrents for most content. WireGuard confinement prevents IP leaks.
**Alternatives considered:** qBittorrent-only (rejected — NZB is preferred), no VPN (rejected — IP exposure risk).

### 50-53: Streaming Stack
**Decision:** Jellyfin, Navidrome, and Audiobookshelf under single toggle. Hardware-accelerated transcoding via Intel QuickSync. Priority on Jellyfin process to prevent streaming stutters.
**Rationale:** QuickSync offloads transcoding from the weak i3 CPU. Single toggle simplifies management. Process priority prevents playback issues.
**Alternatives considered:** Plex (rejected — not self-hosted friendly), software transcoding (rejected — CPU too weak).

### 50-54: Media Discovery
**Decision:** Jellyseerr for self-hosted media request management. Family-friendly request workflow. Integration with Sonarr/Radarr.
**Rationale:** Jellyseerr provides a user-friendly request portal for family members. Automates the request → download workflow.
**Alternatives considered:** Ombi (rejected — Jellyseerr is more actively maintained).

### 50-55: Jellyfin
**Decision:** Hardware-accelerated transcoding via QuickSync. Tier C (HDD) as read-only library. Transcode cache on Tier B (SSD).
**Rationale:** QuickSync is essential for the i3-9100. Read-only Tier C protects media archive. SSD transcode cache prevents HDD thrashing.
**Alternatives considered:** Software transcoding (rejected — CPU insufficient), no transcode cache (rejected — HDD bottleneck).

### 50-56: Sonarr
**Decision:** TV series manager. Download client: SABnzbd. Output: Tier C. Profile: 1080p/4K. Language: DE+EN.
**Rationale:** Sonarr automates TV series collection. Dual language supports German and English content.
**Alternatives considered:** Manual download (rejected — not sustainable).

### 50-57: Radarr
**Decision:** Movie manager. Like Sonarr but for films. Collections auto-download. 4K profile for Q958 QuickSync capability.
**Rationale:** Radarr automates movie collection. QuickSync handles 4K transcoding.
**Alternatives considered:** Manual download (rejected — not sustainable).

### 50-58: Prowlarr
**Decision:** Central indexer manager for all *arr services. Auto-sync to Sonarr/Radarr/Lidarr.
**Rationale:** Single indexer configuration propagated to all *arr services. Eliminates duplicate indexer setup.
**Alternatives considered:** Per-service indexers (rejected — duplicate configuration).

### 50-59: Lidarr
**Decision:** Music downloader and library manager. Native NixOS module (not container-based). Declarative, follows hardening-by-default.
**Rationale:** Completes the *arr suite for music. Native NixOS module ensures declarative, reproducible config.
**Alternatives considered:** Container-based (rejected — violates native NixOS philosophy).

---

## Consequences

### Positive
- Complete automated media pipeline: request → download → organize → stream
- Hardware transcoding enables 4K playback on weak CPU
- Shared GID 169 eliminates permission issues across services
- VPN-confined downloads prevent IP exposure
- Single toggles reduce configuration complexity

### Negative
- Media stack is the most resource-intensive domain
- Indexer availability depends on external sources
- Download stack VPN adds latency
- Large media library requires careful storage management (Domain 30)

---

## Module Inventory

| Module | Purpose |
|--------|---------|
| 50-lib-media.nix | Centralized media paths, shared GID 169 |
| 51-arr-stack.nix | Sonarr + Radarr + Prowlarr single toggle |
| 52-download.nix | SABnzbd with WireGuard confinement |
| 53-streaming.nix | Jellyfin + Navidrome + Audiobookshelf |
| 54-discovery.nix | Jellyseerr media requests |
| 55-jellyfin.nix | Media server with QuickSync transcoding |
| 56-sonarr.nix | TV series automation |
| 57-radarr.nix | Movie automation |
| 58-prowlarr.nix | Central indexer manager |
| 59-lidarr.nix | Music automation |

---

## Cross-Domain Dependencies

- Depends on: Domain 00 (core, PostgreSQL), Domain 10 (network, Caddy), Domain 30 (storage, tiers)
- Used by: Domain 40 (monitoring, health checks on media services)
