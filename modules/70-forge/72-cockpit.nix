# ---NIXMETA
# ---
# domain: 70
# id: "NIXH-70-CKP-001"
# title: "Cockpit Web Admin"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [cockpit, admin]
# description: "Cockpit Web Admin module."
# path: "modules/70-forge/72-cockpit.nix"
# provides: [my.forge.cockpit]
# requires: [10-network/10-network]
# links:
#   adr: docs/adr/ADR-70-cockpit.md
#   guide: docs/guides/70-cockpit.md
#   module: modules/70-forge/72-cockpit.nix
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
 cfg = config.my.services.cockpit;
 dnsMap = import ./dns-map.nix { inherit config; };
 host = dnsMap.dnsMapping.cockpit;
 port = config.my.ports.cockpit;
in
{
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
