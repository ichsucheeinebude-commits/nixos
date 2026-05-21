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

# ---
# nms_id: APP-TOOLS-COUCHDB
# title: CouchDB (hardened)
# capabilities: [ "nosql", "database" ]
# status: "hardened"
# tier_strategy: "ABC-v5.1"
# ---
{ config, lib, pkgs, myLib, ... }:
let
 # 🚀 NMS v4.2 Metadaten (hardened CouchDB)
 nms = {
 id = "NIXH-60-APP-002";
 title = "CouchDB (hardened)";
 description = "Hardened NoSQL database for Obsidian LiveSync.";
 layer = 60;
 nixpkgs.category = "services/databases";
 capabilities = [ "database/nosql" "obsidian/sync" ];
 audit.last_reviewed = "2026-04-27";
 audit.complexity = 1;
 };

 cfg = config.my.services.couchdb;
 port = config.my.ports.couchdb;

in
{
 options.my.meta.couchdb = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 };

 config = lib.mkIf cfg.enable (lib.mkMerge [
 # 🏆 Use the hardened Service Factory
 (myLib.mkService {
 inherit config port;
 name = "couchdb";
 description = "CouchDB NoSQL Database";
 useSSO = true; # Protected via SSO for web access (Fauxton)
 persist = true;
 })

 {
 services.couchdb = {
 enable = true;
 bindAddress = "127.0.0.1";
 };
 }
 ]);
}
/**
 * ---
 * technical_integrity:
 * checksum: sha256:1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b
 * eof_marker: NIXHOME_VALID_EOF
 * ---
 */
