# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-RAD-001"
# title: "Radarr Movies"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [radarr, movies]
# description: "Radarr Movies module."
# path: "modules/50-media/57-radarr.nix"
# provides: [my.media.radarr]
# requires: [50-media/51-arr-stack]
# links:
#   adr: docs/adr/ADR-50-radarr.md
#   guide: docs/guides/50-radarr.md
#   module: modules/50-media/57-radarr.nix
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, utils, myLib, ... }:
let
  arrFactory = import ./_arr-factory.nix { inherit config lib pkgs utils myLib; };
in
arrFactory.mkArr {
  name = "radarr";
  description = "Radarr Movie Downloader";
  id = "NIXH-01-APP-RAD-001";
  port = 7878;
  extraReadWritePaths = [ 
    config.my.configs.paths.mediaLibrary
    config.my.configs.paths.downloads
  ];
}
