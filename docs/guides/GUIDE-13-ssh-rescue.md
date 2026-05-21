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
  module: "modules/placeholder.nix"
---

# Guide: SSH Rescue Guide

```nix\nmy.network.sshRescue.enable = true;\nmy.network.sshRescue.authorizedKeys = [ "ssh-ed25519 ..." ];\n```
