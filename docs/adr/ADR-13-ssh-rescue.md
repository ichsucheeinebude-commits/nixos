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
  module: "modules/10-network/13-ssh-rescue.nix"
---

# ADR: SSH Rescue

## Decision
Separate unit, different port, key-only.


---

## KB Nuggets

### 5-Minuten Rescue Window
Nach jedem Boot öffnet sich ein 5-Minuten-Fenster für Rescue-SSH Zugang. Dann automatisch geschlossen.
