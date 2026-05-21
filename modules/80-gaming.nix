# ---NIXMETA
---
domain: 80
id: "NIXH-80-GAM-001"
title: "Gaming and Game Servers"
type: module
status: draft
complexity: 2
reviewed: YYYY-MM-DD
tags:
  - gaming
  - amp
  - fhs
  - game-servers
description: "FHS game servers, AMP"
provides:
  - my.gaming.enable
requires:
  - 00-core
  - 10-network
  - 30-storage
links:
  adr: ADR-80-gaming.md
  guide: 80-gaming.md
  module: modules/80-gaming.nix
---
# ---ENDNIXMETA

---
#
# PURPOSE: FHS game servers, AMP.
# Key decisions: docs/adr/ADR-80-gaming.md

{ config, lib, pkgs, ... }:

# ── Gaming Module ─────────────────────────────────────────────────────

{
  options.my.gaming = {
    enable = lib.mkEnableOption "gaming module";
  };

  config = lib.mkIf config.my.gaming.enable {
    # TODO: FHS game servers, AMP
  };
}
