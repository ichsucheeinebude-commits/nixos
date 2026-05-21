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

{ config, lib, myLib, ... }:
let
 # 🚀 NMS v4.0 Metadaten
 nms = {
 id = "NIXH-60-APP-003";
 title = "Filebrowser (SRE Hardened)";
 description = "Web-based file manager with strict path restrictions and sandboxing.";
 layer = 60;
 nixpkgs.category = "services/web-apps";
 capabilities = [ "web/file-management" "security/sandboxing" ];
 audit.last_reviewed = "2026-03-02";
 audit.complexity = 2;
 };

 port = config.my.ports.filebrowser;
 domain = config.my.configs.identity.domain;
in
{
 options.my.meta.filebrowser = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 description = "NMS metadata for filebrowser module";
 };

 options.my.services.filebrowser = {
   enable = lib.mkEnableOption "Filebrowser Web-UI";
 };

 config = lib.mkIf config.my.services.filebrowser.enable (lib.mkMerge [
   (myLib.mkService {
     inherit config;
     name = "filebrowser";
     port = port;
     useSSO = true;
     description = "Filebrowser Web-Manager";
     persist = true;
     readWritePaths = [ config.my.configs.paths.storagePool ];
   })
   {
     services.filebrowser = { 
       enable = true; 
       settings = { 
         port = port; 
         address = "127.0.0.1"; 
         root = config.my.configs.paths.storagePool; 
       }; 
     };
     services.caddy.virtualHosts."files.${domain}" = { extraConfig = "import family_auth\nreverse_proxy 127.0.0.1:${toString port}"; };
   }
 ]);
}
