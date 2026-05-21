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
