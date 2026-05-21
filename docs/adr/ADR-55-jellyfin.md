---
domain: 50
id: "NIXH-50-MED-006"
title: "Jellyfin"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [media,jellyfin]
description: "Jellyfin media server."
path: "docs/adr/ADR-55-jellyfin.md"
links:
  module: "modules/50-media/55-jellyfin.nix"
---

# ADR: Jellyfin

## Decision
Hardware-accelerated transcoding option.


---

## KB Nuggets

=== Jellyfin High-Performance Streaming
QuickSync Transcoding. Tier C als readonly Library. Transcode-Cache auf Tier B.
