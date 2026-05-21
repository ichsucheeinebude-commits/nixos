---
domain: 50
id: "NIXH-50-MED-008"
title: "Radarr Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [media,radarr]
description: "Configure Radarr."
path: "docs/guides/GUIDE-57-radarr.md"
links:
  module: "modules/50-media/57-radarr.nix"
---

# Guide: Radarr Guide

Usually enabled via my.media.arr.enable.


---

## KB Nuggets

=== Radarr Config
4K-Profile nur für Filme < 50GB (QuickSync-Limit). HDR-Tone-Mapping für SDR-Clients.

---
## Radarr MASTER-CONFIG (from KB)

---
title: 📚 Radarr MASTER-VARIABLE-LIST (v1.0)
category: architecture/reference
status: [ACTIVE-SSoT]
sources: [https://github.com/Radarr/Radarr]
---

# 📚 Radarr: Konfigurations-Referenz

RADARR_CONSOLE_PROCESS_NAME
RADARR__LOG__CONSOLEFORMAT
RADARR_PROCESS_NAME
RADARR_TESTS_LOG_OUTPUT

## 🚀 SRE-Anwendung
Radarr wird in NixOS primär über \`services.radarr\` gesteuert.
- **Port:** Standard 7878.
- **DataDir:** Standard \`/var/lib/radarr\`.
