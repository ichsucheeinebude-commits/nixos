# ---NIXMETA
# ---
# domain: USER
# id: "NIXH-USER-REPLACE_USER"
# title: "User Home: REPLACE_USER"
# type: user
# status: draft
# complexity: 1
# reviewed: YYYY-MM-DD
# tags:
#   - user
#   - home-manager
# description: "Home Manager configuration for REPLACE_USER"
# provides: []
# requires: []
# links:
#   adr: docs/adr/ADR-00-core.md
#   guide: docs/guides/00-core.md
#   module: modules/00-core.nix
# ---
# ---ENDNIXMETA

{ config, pkgs, lib, ... }:

{
  home.username      = "REPLACE_USER";
  home.homeDirectory = "/home/REPLACE_USER";

  # --- User Packages ---
  home.packages = with pkgs; [
    htop
    git
    # ... weitere CLI Tools
  ];

  # --- Program Configs ---
  programs.git = {
    enable    = true;
    userName  = "REPLACE_USER";
    userEmail = "REPLACE_USER@example.com";
  };

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
