# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-MNC-001"
# title: "Monica CRM"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [monica, crm]
# description: "Monica CRM module."
# path: "modules/60-apps/68-monica.nix"
# provides: [my.apps.monica]
# requires: [10-network/10-network]
# links:
#   adr: docs/adr/ADR-60-monica.md
#   guide: docs/guides/60-monica.md
#   module: modules/60-apps/68-monica.nix
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

# ---
# nms_id: APP-SOCIAL-MONICA
# title: Monica CRM
# capabilities: ["social/crm"]
# status: "hardened"
# tier_strategy: "ABC-v5.1"
# ---
{ config, lib, myLib, ... }:
let
 port = config.my.ports.monica;
 domain = config.my.configs.identity.domain;
 stateDir = "${config.my.configs.paths.stateDir}/monica";
 appKeyFile = "${stateDir}/app-key";
in
{
 options.my.meta.monica = lib.mkOption { type = lib.types.attrs; default = nms; readOnly = true; };
 
 options.my.services.monica = {
   enable = lib.mkEnableOption "Monica CRM";
 };

 config = lib.mkIf config.my.services.monica.enable (lib.mkMerge [
   (myLib.mkService {
     inherit config;
     name = "monica";
     port = port;
     useSSO = true;
     description = "Monica Personal CRM";
     requiresPostgres = true;
     persist = true;
     readWritePaths = [ stateDir ];
   })
   {
     services.monica = { 
       enable = true; 
       hostname = "monica.${domain}"; 
       appURL = "https://monica.${domain}"; 
       inherit appKeyFile; 
       nginx.listen = [ { addr = "127.0.0.1"; port = port; ssl = false; } ]; 
       database.createLocally = true; 
     };
     services.caddy.virtualHosts."monica.${domain}" = { extraConfig = "import family_auth\nreverse_proxy 127.0.0.1:${toString port}"; };
     system.activationScripts.monicaAppKeyFile.text = "install -d -m 0750 -o monica -g monica ${stateDir}; if [ ! -s ${appKeyFile} ]; then head -c 32 /dev/urandom | base64 > ${appKeyFile}; fi";
     
     systemd.services.phpfpm-monica = {
       after = [ "postgresql.service" ];
       # Additional paths for phpfpm instance
       serviceConfig.ReadWritePaths = [ stateDir ];
     };
   }
 ]);
}
