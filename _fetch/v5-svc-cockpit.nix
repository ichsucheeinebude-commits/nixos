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

{ config, lib, pkgs, ... }:
let
 nms = { id = "NIXH-80-MON-001"; title = "Cockpit"; description = "Web admin."; layer = 80; nixpkgs.category = "tools/admin"; capabilities = [ "system/administration" ]; audit.last_reviewed = "2026-03-02"; audit.complexity = 1; };
 cfg = config.my.services.cockpit;
 dnsMap = import ./dns-map.nix { inherit config; };
 host = dnsMap.dnsMapping.cockpit;
 port = config.my.ports.cockpit;
in
{
 options.my.meta.cockpit = lib.mkOption { type = lib.types.attrs; default = nms; readOnly = true; };
 config = lib.mkIf cfg.enable {
 services.cockpit = { 
   enable = true; 
   port = port; 
   package = pkgs.cockpit; 
   settings = { 
     WebService = { 
       AllowUnencrypted = true; 
       ProtocolHeader = "X-Forwarded-Proto"; 
     }; 
     Session = { 
       IdleTimeout = 15; 
     }; 
   }; 
 };

 services.caddy.virtualHosts."${host}" = { 
   extraConfig = ''
     import family_auth
     reverse_proxy 127.0.0.1:${toString port}
   '';
 };

 # 🛡️ SYSTEMD SANDBOXING
 systemd.services.cockpit.serviceConfig = {
   OOMScoreAdjust = -500;
   ProtectSystem = "strict";
   ProtectHome = true;
   PrivateTmp = true;
   PrivateDevices = true;
   NoNewPrivileges = true;
   RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
   SystemCallFilter = [ "@system-service" "@privileged" "~@resources" ];
   MemoryMax = "512M";
   CPUWeight = 30;
 };
 };
}
