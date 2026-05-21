# ---NIXMETA
# ---
# domain: USER
# id: "NIXH-USER-REPLACE_USER"
# title: "User: REPLACE_USER"
# type: user
# status: draft
# complexity: 1
# reviewed: YYYY-MM-DD
# tags:
#   - user
# description: "User configuration for REPLACE_USER"
# provides: []
# requires: []
# links:
#   adr: docs/adr/ADR-00-core.md
#   guide: docs/guides/00-core.md
#   module: modules/00-core.nix
# ---
# ---ENDNIXMETA

{ config, pkgs, ... }:

{
  users.users."REPLACE_USER" = {
    isNormalUser  = true;
    description   = "REPLACE_USER";
    extraGroups   = [ "networkmanager" "wheel" ];
    shell         = pkgs.bash;
  };
}
