# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-AUTO-GEN",
#   "title": "Auto Generated",
#   "layer": 99,
#   "category": "auto/gen",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["auto-generated"],
#   "description": "Auto-migrated module to NIXMETA 2.0."
# }
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
