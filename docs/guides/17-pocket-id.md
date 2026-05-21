---
domain: 10
id: "NIXH-10-NET-008"
title: "Pocket-ID Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,oidc]
description: "Configure Pocket-ID."
path: "docs/guides/GUIDE-17-pocket-id.md"
links:
  module: "modules/10-network/17-pocket-id.nix"
---

# Guide: Pocket-ID Guide

```nix
my.network.pocketId.enable = true;
```


---

## KB Nuggets

### PocketID Setup
OIDC Identity Provider mit Generic OIDC Backend. CF Access leitet zu Pocket-ID weiter → bei Erfolg Weiterleitung zum Service.
