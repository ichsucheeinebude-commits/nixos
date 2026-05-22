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

### 50-51: Arr Stack (nixflix + nixarr patterns)
**Decision:** Sonarr, Radarr, Prowlarr, Readarr, Lidarr enabled via single toggle. State management in `/data/.state/nixarr/` with structured backup exclusion (Arr data is re-downloadable, NOT in backup). theme.park integration for unified theming across all Arr services. TRaSH-Guides quality profiles (1080p H.265, good file size).
**Rationale:** Single toggle reduces configuration complexity. State directory structure enables clear backup policies. theme.park provides consistent UI. TRaSH-Guides profiles optimize for file size without sacrificing quality.
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

### 50-55: Jellyfin (upgraded)
**Decision:** Hardware-accelerated transcoding via QuickSync (iHD driver). Plugin management (AniDB, AniList, TMDB, TVDB, OpenSubtitles). theme.park integration. Auto-library generation from Arr root folders. State management in `/data/.state/nixarr/jellyfin/`. Cache and transcodes excluded from backup (regenerable).
**Rationale:** QuickSync is essential for the i3-9100. Plugins enhance metadata and subtitle quality. Auto-libraries reduce manual configuration.
**Alternatives considered:** Software transcoding (rejected — CPU insufficient), no plugins (rejected — poor metadata).

### 50-56: Sonarr (upgraded)
**Decision:** TV series manager with TRaSH-Guides quality profile (1080p H.265, max 4GB per episode). theme.park integration for consistent UI. State in `/data/.state/nixarr/sonarr/` (excluded from backup). systemd hardening with ProtectSystem=strict, ReadWritePaths scoped to state dir + media.
**Rationale:** H.265 provides smaller files at good quality. theme.park matches other Arr services. Scoped state directory enables clear backup policy.
**Alternatives considered:** H.264 (rejected — larger files for same quality).

### 50-57: Radarr (upgraded)
**Decision:** Movie manager with TRaSH-Guides quality profile (1080p H.265, 500MB-8GB). theme.park integration. State in `/data/.state/nixarr/radarr/` (excluded from backup). systemd hardening.
**Rationale:** H.265 provides 3-6GB typical for 1080p movies. theme.park matches other Arr services.
**Alternatives considered:** 4K profile (rejected — storage cost vs quality benefit on i3-9100).

### 50-58: Prowlarr (upgraded)
**Decision:** Central indexer manager with declarative settings sync. SceneNZB.com as sole indexer (Newznab API v1, REST). theme.park integration. State in `/data/.state/nixarr/prowlarr/` (excluded from backup).
**Rationale:** Single authoritative indexer reduces complexity. SceneNZB provides high-quality NZB content. Declarative sync ensures reproducible configuration.
**Alternatives considered:** Multiple indexers (rejected — user preference for single source).

### 50-59: Lidarr (upgraded)
**Decision:** Music downloader with TRaSH-Guides quality profile (lossless preferred). theme.park integration. State in `/data/.state/nixarr/lidarr/` (excluded from backup). systemd hardening.
**Rationale:** Lossless music provides best quality. theme.park matches other Arr services.
**Alternatives considered:** 320kbps (rejected — lossless preferred for archival).

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
| 51-arr-stack.nix | Arr stack library: theme.park, TRaSH-Guides, state management |
| 52-download.nix | SABnzbd with WireGuard VPN confinement (downloads only) |
| 53-streaming.nix | Jellyfin + Navidrome + Audiobookshelf |
| 54-discovery.nix | Jellyseerr media requests |
| 55-jellyfin.nix | Media server: QuickSync, plugins, auto-libraries, theme.park |
| 56-sonarr.nix | TV series: TRaSH-Guides 1080p/H.265, theme.park |
| 57-radarr.nix | Movies: TRaSH-Guides 1080p/H.265, theme.park |
| 58-prowlarr.nix | Indexer: SceneNZB.com declarative sync, theme.park |
| 59-lidarr.nix | Music: TRaSH-Guides lossless, theme.park |
| 60-readarr.nix | Books: theme.park, state management |
| 63-seerr.nix | Media requests: cross-service integration, theme.park |

---

## Cross-Domain Dependencies

- Depends on: Domain 00 (core, PostgreSQL), Domain 10 (network, Caddy), Domain 30 (storage, tiers)
- Used by: Domain 40 (monitoring, health checks on media services)
