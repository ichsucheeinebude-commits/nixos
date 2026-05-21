# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-002"
# title: "n8n Automation"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [apps,n8n,workflows]
# description: "n8n workflow automation platform."
# path: "modules/60-apps/61-n8n.nix"
# provides: [my.apps.n8n]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/60-apps/61-n8n.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.apps.n8n = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 5678; };
    databaseType = lib.mkOption { type = lib.types.enum [ "sqlite" "postgres" ]; default = "postgres"; };
    memoryMax = lib.mkOption { type = lib.types.str; default = "2G"; };
  };
}
