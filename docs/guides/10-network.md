---
domain: 10
id: "NIXH-10-NET-001"
title: "Network Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network]
description: "Configure networking."
path: "docs/guides/GUIDE-10-network.md"
links:
  module: "modules/10-network/10-network.nix"
---

# Guide: Network Guide

Defaults are safe for most setups.


---

## KB Nuggets

### Network Interface Stability
MAC-basierte Interface-Namen (`networking.useNetworkd = true`) verhindern Namen-Swap nach Hardware-Änderungen.
