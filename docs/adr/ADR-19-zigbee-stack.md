---
domain: 10
id: "NIXH-10-NET-010"
title: "Zigbee Stack"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,zigbee,mqtt]
description: "Mosquitto + Zigbee2MQTT."
path: "docs/adr/ADR-19-zigbee-stack.md"
links:
  module: "modules/10-network/19-zigbee-stack.nix"
---

# ADR: Zigbee Stack

## Decision
Local MQTT broker, Zigbee2MQTT frontend.


---

## KB Nuggets

### Zigbee2MQTT + Mosquitto
Native systemd-Services (kein Docker!). Zigbee-Stick direkt an den Host, MQTT als Message-Bus.
