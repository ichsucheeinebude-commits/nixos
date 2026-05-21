---
domain: 50
id: "NIXH-50-MED-003"
title: "Download Stack"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [media,download]
description: "SABnzbd downloader."
path: "docs/adr/ADR-52-download.md"
links:
  module: "modules/50-media/52-download.nix"
---

# ADR: Download Stack

## Decision
SABnzbd for NZB downloads.


---

## KB Nuggets

=== Download VPN-Confinement
SABnzbd + qBittorrent im WireGuard-Namespace. Kein Leak möglich.
