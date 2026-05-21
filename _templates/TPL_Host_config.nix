# ---NIXMETA
---
domain: HOST
id: "NIXH-HOST-REPLACE_HOSTNAME"
title: "Host: REPLACE_HOSTNAME"
type: host
status: draft
complexity: 3
reviewed: YYYY-MM-DD
tags:
  - host
description: "Host-specific configuration for REPLACE_HOSTNAME"
provides: []
requires:
  - 00-core
links:
  adr: docs/adr/ADR-00-core.md
  guide: docs/guides/00-core.md
  module: modules/00-core.nix
---
# ---ENDNIXMETA

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-nixos.nix
    # ../../modules/00-core.nix
    # ../../modules/10-network.nix
    # Weitere Module nach Bedarf
  ];

  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "REPLACE_HOSTNAME";
  time.timeZone       = "Europe/Berlin";
  i18n.defaultLocale  = "de_DE.UTF-8";

  system.stateVersion = "24.11";
}
