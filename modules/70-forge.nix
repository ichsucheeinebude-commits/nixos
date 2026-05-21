# ---NIXMETA
---
domain: 70
id: "NIXH-70-FOR-001"
title: "Forge Self-Hosted Git"
type: module
status: draft
complexity: 2
reviewed: YYYY-MM-DD
tags:
  - forgejo
  - git
  - ci-cd
description: "Forgejo, CI/CD, sovereign Git"
provides:
  - my.forge.enable
requires:
  - 00-core
  - 10-network
  - 20-security
links:
  adr: ADR-70-forge.md
  guide: 70-forge.md
  module: modules/70-forge.nix
---
# ---ENDNIXMETA

---
#
# PURPOSE: Forgejo, CI/CD, sovereign Git.
# Key decisions: docs/adr/ADR-70-forge.md

{ config, lib, pkgs, ... }:

# ── Forge Module ──────────────────────────────────────────────────────

{
  options.my.forge = {
    enable = lib.mkEnableOption "forge module";
  };

  config = lib.mkIf config.my.forge.enable {
    # TODO: Forgejo, CI/CD
  };
}
