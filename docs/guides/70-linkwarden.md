# Linkwarden — Bookmark Manager

**Module:** `modules/60-apps/70-linkwarden.nix`  
**Domain:** 60-apps  
**Complexity:** ⭐⭐

## Overview

Collaborative bookmark manager with automatic archiving and DynamicUser sandboxing.

## Enable

```nix
my.apps.linkwarden.enable = true;
```

## Access

Available at: `https://links.<domain>`

## Sandboxing

- DynamicUser = true
- ProtectSystem = strict
- ProtectHome = true
- PrivateTmp = true
- PrivateDevices = true
- SystemCallFilter = ["@system-service" "~@privileged"]
- OOMScoreAdjust = 300
