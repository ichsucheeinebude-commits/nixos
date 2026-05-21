# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-PRO-001"
# title: "Prowlarr Indexer"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [prowlarr, indexer]
# description: "Prowlarr Indexer module."
# path: "modules/50-media/58-prowlarr.nix"
# provides: [my.media.prowlarr]
# requires: [50-media/51-arr-stack]
# links:
#   adr: docs/adr/ADR-50-prowlarr.md
#   guide: docs/guides/50-prowlarr.md
#   module: modules/50-media/58-prowlarr.nix
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, utils, myLib, ... }:
let
  arrFactory = import ./_arr-factory.nix { inherit config lib pkgs utils myLib; };
in
arrFactory.mkArr {
  name = "prowlarr";
  description = "Prowlarr Indexer Manager";
  id = "NIXH-01-APP-PRO-001";
  port = 9696;
}
