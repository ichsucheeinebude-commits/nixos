---
domain: 50
id: "NIXH-50-DOM-001"
title: "Domain 50 — Media Guide"
type: guide
status: draft
complexity: 2
reviewed: 2026-05-21
tags:
  - domain
  - 50
  - media
  - operations
description: "Operational guide for the 50-media domain."
links:
  adr: ADR-50-media.md
  guide: 50-media.md
---

# 50-media: Domain Media Guide

> Operational procedures for the complete media stack: library management, *arr automation, downloads, streaming, and hardware transcoding.

---

## Prerequisites

- Domain 00 (core, PostgreSQL) deployed
- Domain 10 (network, Caddy) for reverse proxy
- Domain 30 (storage, ABC tiers) configured
- Intel QuickSync available (UHD 630 on Q958)
- Shared GID 169 created

---

## Module Operations (ODR-sorted)

### 50-50: Media Library
**Enable:** Configure media paths in host config. All services share GID 169.
**Verify:** `getent group media` shows GID 169 with all service users. `ls -la /mnt/media/` shows correct ownership.
**Troubleshooting:** Permission denied — verify GID 169 membership. Check read-only mounts for library paths.

### 50-51: Arr Stack
**Enable:** `my.media.arrStack.enable = true;` Enables Sonarr + Radarr + Prowlarr.
**Verify:** All three web UIs accessible. Prowlarr shows synced indexers to Sonarr/Radarr.
**Troubleshooting:** API key mismatch — check auto-wiring. Database errors — verify PostgreSQL connection.

### 50-52: Download Stack
**Enable:** `my.media.download.enable = true;` SABnzbd with WireGuard namespace.
**Verify:** SABnzbd web UI accessible. `wg show` shows active WireGuard tunnel. IP check from SABnzbd shows VPN IP.
**Troubleshooting:** Download not starting — check indexer connection. VPN not connected — verify WireGuard config.

### 50-53: Streaming Stack
**Enable:** `my.media.streaming.enable = true;` Enables Jellyfin + Navidrome + Audiobookshelf.
**Verify:** Jellyfin web UI accessible. Playback works. `intel_gpu_top` shows QuickSync usage during transcoding.
**Troubleshooting:** Transcoding fails — verify `intel-compute-runtime` installed. Playback stuttering — check process priority.

### 50-54: Media Discovery
**Enable:** `my.media.discovery.enable = true;` Jellyseerr for media requests.
**Verify:** Jellyseerr web UI accessible. Test request flows to Sonarr/Radarr.
**Troubleshooting:** Request not processing — check Sonarr/Radarr API connection in Jellyseerr settings.

### 50-55: Jellyfin
**Enable:** `my.media.jellyfin.enable = true;` Configure QuickSync transcoding, library paths, transcode cache on Tier B.
**Verify:** `vainfo` shows codec support. Playback with transcoding: check `intel_gpu_top` during playback.
**Troubleshooting:** No hardware acceleration — verify GPU device permissions. Transcode cache full — clean Tier B.

### 50-56: Sonarr
**Enable:** Enabled via arr-stack toggle. Configure TV library path, download client, quality profiles.
**Verify:** Series library populated. Downloads arriving on Tier C.
**Troubleshooting:** Import failing — check file permissions (GID 169). Download client not connecting — verify SABnzbd API key.

### 50-57: Radarr
**Enable:** Enabled via arr-stack toggle. Configure movie library path, quality profiles (1080p/4K).
**Verify:** Movie library populated. 4K movies transcode successfully.
**Troubleshooting:** 4K transcoding fails — verify QuickSync HEVC support.

### 50-58: Prowlarr
**Enable:** Enabled via arr-stack toggle. Add indexers, configure sync to *arr services.
**Verify:** Indexers show green status. Sync status in Prowlarr shows connected apps.
**Troubleshooting:** Indexer timeout — check network connectivity. Sync failed — verify API keys.

### 50-59: Lidarr
**Enable:** `my.media.lidarr.enable = true;` Configure music library path, download client.
**Verify:** Music library populated. Downloads arriving correctly.
**Troubleshooting:** Music not imported — check file naming convention. Download client not connecting — verify SABnzbd.

---

## Cross-Domain Interactions

- Depends on: Domain 00 (core, PostgreSQL), Domain 10 (network, Caddy), Domain 30 (storage tiers)
- Used by: Domain 40 (monitoring, health checks)
