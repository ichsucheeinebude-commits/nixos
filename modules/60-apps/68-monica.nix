# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-009"
# title: "Monica CRM"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [apps,monica,crm]
# description: "Monica personal CRM."
# path: "modules/60-apps/68-monica.nix"
# provides: [my.apps.monica]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/60-apps/68-monica.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.apps.monica = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 8095; };
  };
}
