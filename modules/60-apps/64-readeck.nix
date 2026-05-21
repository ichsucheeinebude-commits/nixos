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

# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-050-KNW-REA-001",
#   "title": "Readeck Reader",
#   "layer": 50,
#   "category": "services/web-apps",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["knowledge", "reader", "read-it-later", "hardened"],
#   "description": "Self-hosted 'read-it-later' service, tightly sandboxed with DynamicUser."
# }
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
let
 
 port = config.my.ports.readeck;
 domain = config.my.configs.identity.domain;
in
{
 options.my.meta.readeck = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 description = "NMS metadata for readeck module";
 };


 # 📚 READECK KNOWLEDGE (anchor: readeck-knowledge)
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
