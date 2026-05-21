---
domain: 40
id: "NIXH-40-MON-005"
title: "Vector Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [monitoring,vector]
description: "Configure Vector."
path: "docs/guides/GUIDE-44-vector.md"
links:
  module: "modules/40-monitoring/44-vector.nix"
---

# Guide: Vector Guide

Set logDir for output.


---

## KB Nuggets

=== Vector Konfiguration
Sources: journald, Service-Logs. Transforms: Filter, Parse. Sinks: Files, Ntfy, optional Loki.
