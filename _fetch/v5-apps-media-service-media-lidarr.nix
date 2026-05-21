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
  name = "lidarr";
  description = "Lidarr Music Downloader";
  id = "NIXH-01-APP-LID-001";
  port = 8686;
  extraReadWritePaths = [ 
    config.my.configs.paths.mediaLibrary
    config.my.configs.paths.downloads
  ];
}
