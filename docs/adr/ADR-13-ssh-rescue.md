---
domain: 10
id: "NIXH-10-NET-004"
title: "SSH Rescue"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,ssh,rescue]
description: "Secondary SSH for emergency access."
path: "docs/adr/ADR-13-ssh-rescue.md"
links:
  module: "modules/placeholder.nix"
---

# ADR: SSH Rescue

## Decision\nSeparate systemd unit, different port, key-only.
