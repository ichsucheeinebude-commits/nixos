# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-SON-001"
# title: "Sonarr TV"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [sonarr, tv]
# description: "Sonarr TV module."
# path: "modules/50-media/56-sonarr.nix"
# provides: [my.media.sonarr]
# requires: [50-media/51-arr-stack]
# links:
#   adr: docs/adr/ADR-50-sonarr.md
#   guide: docs/guides/50-sonarr.md
#   module: modules/50-media/56-sonarr.nix
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, utils, myLib, ... }:
let
  arrFactory = import ./_arr-factory.nix { inherit config lib pkgs utils myLib; };
in
arrFactory.mkArr {
  name = "sonarr";
  description = "Sonarr TV Series Downloader";
  id = "NIXH-01-APP-SON-001";
  port = 8989;
  stateDirName = "NzbDrone"; # Sonarr special case
  extraReadWritePaths = [ 
    config.my.configs.paths.mediaLibrary
    config.my.configs.paths.downloads
  ];
}
