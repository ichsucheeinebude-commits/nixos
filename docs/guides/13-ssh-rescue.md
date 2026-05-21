---
domain: 10
id: "NIXH-10-NET-004"
title: "SSH Rescue Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,ssh,rescue]
description: "Enable rescue SSH."
path: "docs/guides/GUIDE-13-ssh-rescue.md"
links:
  module: "modules/10-network/13-ssh-rescue.nix"
---

# Guide: SSH Rescue Guide

```nix
my.network.sshRescue.enable = true;
```


---

## KB Nuggets

### Rescue Window Implementierung
Timer-basierter SSH-Port der nur nach Boot für 5 Minuten lauscht. Fallback bei Lockout.
