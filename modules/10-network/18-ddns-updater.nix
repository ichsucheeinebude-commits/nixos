# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-DDN-001"
# title: "DDNS Updater"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [ddns, dynamic]
# description: "DDNS Updater module."
# path: "modules/10-network/18-ddns-updater.nix"
# provides: [my.network.ddns]
# requires: [10-network/10-network]
# links:
#   adr: docs/adr/ADR-10-ddns-updater.md
#   guide: docs/guides/10-ddns-updater.md
#   module: modules/10-network/18-ddns-updater.nix
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

{ config, lib, ... }:
let
 
 domain = config.my.configs.identity.domain;
 port = config.my.ports.ddnsUpdater;
in
{
 options.my.meta.ddns_updater = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 description = "NMS metadata for ddns-updater module";
 };


 config = lib.mkIf config.my.services.ddnsUpdater.enable {
 services.ddns-updater = {
 enable = true;
 environment = { LISTENING_ADDRESS = ":${toString port}"; PERIOD = "10m"; };
 };
 
 systemd.services.ddns-updater.serviceConfig = {
   OOMScoreAdjust = -500;
   ProtectSystem = "strict";
   ProtectHome = true;
   PrivateTmp = true;
   NoNewPrivileges = true;
 };

 services.caddy.virtualHosts."nix-ddns.${domain}" = {
 extraConfig = "import family_auth\nreverse_proxy 127.0.0.1:${toString port}";
 };
 };
}
