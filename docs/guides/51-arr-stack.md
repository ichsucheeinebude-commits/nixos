---
domain: 50
id: "NIXH-50-MED-002"
title: "Arr Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [media,arr]
description: "Configure Arr stack."
path: "docs/guides/GUIDE-51-arr-stack.md"
links:
  module: "modules/50-media/51-arr-stack.nix"
---

# Guide: Arr Guide

```nix
my.media.arr.enable = true;
```


---

## KB Nuggets

=== ARR-Stack Master-Reference
Sonarr (TV), Radarr (Movies), Prowlarr (Indexer). Shared config via mkArr-Factory.

---
## ARR Stack MASTER-CONFIG (from KB)

---
title: 📚 ARR-Stack MASTER-CONFIG-REFERENCE (v1.0)
category: architecture/reference
status: [ACTIVE-SSoT]
sources: [Sonarr, Lidarr, Prowlarr GitHub Orgs]
---

# 📚 ARR-Stack: Gemeinsame Steuer-Variablen

Alle .NET-basierten ARR-Apps folgen demselben Schema für die Initialisierung.

## 🎵 Lidarr
LIDARR_CONSOLE_PROCESS_NAME
LIDARR__LOG__CONSOLEFORMAT
LIDARR_PROCESS_NAME
LIDARR_TESTS_LOG_OUTPUT

## 📺 Sonarr
SONARR_CONSOLE_PROCESS_NAME
SONARR__LOG__CONSOLEFORMAT
SONARR_MAJOR_VERSION
SONARR_PROCESS_NAME
SONARR_TESTS_LOG_OUTPUT
SONARR_VERSION

## 🔍 Prowlarr
PROWLARR_CONSOLE_PROCESS_NAME
PROWLARR__LOG__CONSOLEFORMAT
PROWLARR_PROCESS_NAME
PROWLARR_TESTS_LOG_OUTPUT
