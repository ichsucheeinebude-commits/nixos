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
{ config, lib, pkgs, myLib, ... }:
let

 cfg = config.my.services.karakeep;
 port = config.my.ports.karakeep;
 srePaths = config.my.configs.paths;

in
{

 config = lib.mkIf cfg.enable (lib.mkMerge [
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
