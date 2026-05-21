---
domain: 00
id: "NIXH-00-COR-001"
title: "Principles & Defaults Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [core,principles]
description: "How to use the principles module."
path: "docs/guides/GUIDE-00-principles.md"
links:
  module: "modules/placeholder.nix"
---

# Guide: Principles & Defaults Guide

## Usage\n\nSet in your host configuration:\n\n```nix\nmy.core.principles.bastelmodus = true;  # enable experimental mode\n```\n\nWhen bastelmodus is false, forbidden-technology assertions (Docker, Tailscale, etc.) are strictly enforced.
