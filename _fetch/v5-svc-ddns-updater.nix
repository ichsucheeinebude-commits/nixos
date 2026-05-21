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
 # 🚀 NMS v4.0 Metadaten
 nms = {
 id = "NIXH-10-GTW-004";
 title = "Ddns Updater";
 description = "Automated Dynamic DNS updates for Cloudflare and other providers.";
 layer = 10;
 nixpkgs.category = "services/networking";
 capabilities = [ "network/ddns" "cloudflare/integration" ];
 audit.last_reviewed = "2026-03-02";
 audit.complexity = 1;
 };

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
