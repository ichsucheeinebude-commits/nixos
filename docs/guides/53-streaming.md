---
domain: 50
id: "NIXH-50-MED-004"
title: "Streaming Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [media,streaming]
description: "Configure streaming."
path: "docs/guides/GUIDE-53-streaming.md"
links:
  module: "modules/50-media/53-streaming.nix"
---

# Guide: Streaming Guide

Enable gpuAcceleration for Intel QSV.


---

## KB Nuggets

=== Jellyfin Media Mastery
Hardware-Transcoding via Intel QuickSync (`intel-compute-runtime`). VA-API Device durch HAL-Option.
=== Intel QuickSync NixOS
`hardware.graphics.enable = true` + `intel-compute-runtime` für iGPU-Transcoding. VA-API Device an Jellyfin.

---
## Audiobookshelf MASTER-CONFIG (from KB)

---
title: 📚 Audiobookshelf MASTER-VARIABLE-LIST (v1.0)
category: architecture/reference
status: [ACTIVE-SSoT]
sources: [https://github.com/advplyr/audiobookshelf (Code Extraction)]
---

# 📚 Audiobookshelf: Konfigurations-Referenz

ACCESS_TOKEN_EXPIRY
ALLOW_CORS
ALLOW_IFRAME
BACKUP_PATH
CONFIG_PATH
DISABLE_SSRF_REQUEST_FILTER
EXP_PROXY_SUPPORT
FFMPEG_PATH
FFPROBE_PATH
FLVMETA_PATH
FLVTOOL2_PATH
HOST
JWT_SECRET_KEY
MAX_FAILED_EPISODE_CHECKS
METADATA_PATH
NODE_DEBUG
NODE_ENV
NUSQLITE3_PATH
OSTYPE
PATH
PATHEXT
PODCAST_DOWNLOAD_TIMEOUT
PORT
QUERY_LOGGING
QUERY_PROFILING
RATE_LIMIT_AUTH_MAX
RATE_LIMIT_AUTH_MESSAGE
RATE_LIMIT_AUTH_WINDOW
REACT_CLIENT_PATH
READABLE_STREAM
REFRESH_TOKEN_EXPIRY
ROUTER_BASE_PATH
SKIP_BINARIES_CHECK
SOURCE
SSRF_REQUEST_FILTER_WHITELIST
USE_X_ACCEL

## 🚀 SRE-Anwendung
In NixOS steuern wir ABS via \`services.audiobookshelf\`. Diese Variablen können via \`systemd.services.audiobookshelf.environment\` injiziert werden.
