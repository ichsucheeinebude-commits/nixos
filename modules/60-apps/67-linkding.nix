# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-LNK-001"
# title: "Linkding Bookmarks"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [linkding, bookmarks]
# description: "Linkding Bookmarks module."
# path: "modules/60-apps/67-linkding.nix"
# provides: [my.apps.linkding]
# requires: [10-network/10-network]
# links:
#   adr: docs/adr/ADR-60-linkding.md
#   guide: docs/guides/60-linkding.md
#   module: modules/60-apps/67-linkding.nix
# ---
# ---ENDNIXMETA
# ---
# title: Linkding Bookmarks
# capabilities: ["tools/bookmarks"]
# status: "hardened"
# tier_strategy: "ABC-v5.1"
# ---
{ lib, config, myLib, ... }:
let

 cfg = config.my.services.linkding;
 port = config.my.ports.linkding;
in
{

 options.my.services.linkding.enable = lib.mkEnableOption "Linkding Bookmark Manager";

 config = lib.mkIf cfg.enable (lib.mkMerge [
 (myLib.mkService {
 inherit config port;
 name = "linkding";
 description = "Linkding Bookmark Service";
 useSSO = true;
 })

 {
 services.linkding = {
 enable = true;
 host = "127.0.0.1";
 port = port;
 };

 # Resource Hardening (Systemd-Level)
 systemd.services.linkding.serviceConfig = {
 MemoryMax = "512M";
 CPUWeight = 30;
 };
 }
 ]);
}
