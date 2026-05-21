# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-RDK-001"
# title: "Readeck"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [readeck, read-it-later]
# description: "Readeck module."
# path: "modules/60-apps/64-readeck.nix"
# provides: [my.apps.readeck]
# requires: [10-network/10-network]
# links:
#   adr: docs/adr/ADR-60-readeck.md
#   guide: docs/guides/60-readeck.md
#   module: modules/60-apps/64-readeck.nix
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
 
 port = config.my.ports.readeck;
 domain = config.my.configs.identity.domain;
in
{


 config = lib.mkIf config.my.services.readeck.enable {
 services.readeck = { enable = true; settings = { server.host = "127.0.0.1"; server.port = port; log.level = "info"; }; environmentFile = config.sops.secrets.readeck_env.path; };
 services.caddy.virtualHosts."read.${domain}" = { extraConfig = "import family_auth\nreverse_proxy 127.0.0.1:${toString port}"; };
 systemd.services.readeck.serviceConfig = { 
   DynamicUser = true; 
   StateDirectory = "readeck";
   ProtectSystem = "strict"; 
   ProtectHome = true; 
   PrivateTmp = true; 
   PrivateDevices = true; 
   SystemCallFilter = [ "@system-service" "~@privileged" ]; 
   OOMScoreAdjust = 300; 
 };
 };
}
