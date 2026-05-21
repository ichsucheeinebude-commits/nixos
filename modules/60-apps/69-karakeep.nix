# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-KRK-001"
# title: "Karakeep Bookmarks"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [karakeep, bookmarks]
# description: "Karakeep Bookmarks module."
# path: "modules/60-apps/69-karakeep.nix"
# provides: [my.apps.karakeep]
# requires: [10-network/10-network]
# links:
#   adr: docs/adr/ADR-60-karakeep.md
#   guide: docs/guides/60-karakeep.md
#   module: modules/60-apps/69-karakeep.nix
# ---
# ---ENDNIXMETA

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

{ config, lib, pkgs, myLib, ... }:
let
 # 🚀 NMS v4.2 Metadaten (hardened Karakeep)

 cfg = config.my.services.karakeep;
 port = config.my.ports.karakeep;
 srePaths = config.my.configs.paths;

in
{
 options.my.meta.karakeep = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 };

 config = lib.mkIf cfg.enable (lib.mkMerge [
 # 🏆 Use the hardened Service Factory
 (myLib.mkService {
 inherit config port;
 name = "karakeep";
 description = "Karakeep Bookmark Manager";
 useSSO = true;
 persist = true;
 readWritePaths = [ 
 "${srePaths.stateDir}/karakeep"
 "${srePaths.tierB}/cache/karakeep"
 ];
 })

 {
 services.karakeep = {
 enable = true;
 extraEnvironment = {
 PORT = toString port;
 DISABLE_SIGNUPS = "true";
 };
 };
 }
 ]);
}

