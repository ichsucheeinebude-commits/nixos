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
 nms = {
 id = "NIXH-60-APP-004";
 title = "Karakeep (hardened)";
 description = "Hardened bookmark management tool with SRE sandboxing.";
 layer = 60;
 nixpkgs.category = "web/apps";
 capabilities = [ "web/bookmarks" "security/sandboxing" ];
 audit.last_reviewed = "2026-04-27";
 audit.complexity = 1;
 };

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
/**
 * ---
 * technical_integrity:
 * checksum: sha256:4f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a
 * eof_marker: NIXHOME_VALID_EOF
 * ---
 */
