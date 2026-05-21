---
domain: 10
id: "NIXH-10-NET-009"
title: "DDNS Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,ddns]
description: "Configure DDNS."
path: "docs/guides/GUIDE-18-ddns-updater.md"
links:
  module: "modules/10-network/18-ddns-updater.nix"
---

# Guide: DDNS Guide

Requires provider credentials.


---

## KB Nuggets

### DDNS Updater Konfiguration
Polling alle 5 Minuten. Nur update bei tatsächlicher IP-Änderung. Health-Check via Gatus.
