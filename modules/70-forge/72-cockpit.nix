# ---NIXMETA
# ---
# domain: 70
# id: "NIXH-70-FRG-003"
# title: "Cockpit Admin"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [forge,cockpit,admin]
# description: "Cockpit web administration."
# path: "modules/70-forge/72-cockpit.nix"
# provides: [my.forge.cockpit]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/70-forge/72-cockpit.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.forge.cockpit = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 9090; };
  };

  config = lib.mkIf config.my.forge.cockpit.enable {
    services.cockpit = {
      enable = true;
      port = config.my.forge.cockpit.port;
    };
  };
}
