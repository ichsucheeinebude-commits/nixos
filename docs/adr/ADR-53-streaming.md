---
domain: 50
id: "NIXH-50-MED-004"
title: "Streaming Stack"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [media,streaming]
description: "Jellyfin, Navidrome, Audiobookshelf."
path: "docs/adr/ADR-53-streaming.md"
links:
  module: "modules/50-media/53-streaming.nix"
---

# ADR: Streaming Stack

## Decision
All streaming services under single toggle.


---

## KB Nuggets

=== Media Performance Priority
Schutz vor Rucklern beim Streaming. QuickSync für Hardware-Transcoding. Priorität auf Jellyfin-Prozess.
