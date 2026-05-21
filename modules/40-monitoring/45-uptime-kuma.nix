# ---NIXMETA
# ---
# domain: 40
# id: "NIXH-40-UKM-001"
# title: "Uptime Kuma"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [uptime, monitoring]
# description: "Uptime Kuma module."
# path: "modules/40-monitoring/45-uptime-kuma.nix"
# provides: [my.monitoring.uptime_kuma]
# requires: [40-monitoring/40-gatus]
# links:
#   adr: docs/adr/ADR-40-uptime-kuma.md
#   guide: docs/guides/40-uptime-kuma.md
#   module: modules/40-monitoring/45-uptime-kuma.nix
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
 
 port = config.my.ports.uptimeKuma;
 domain = config.my.configs.identity.domain;
in
{
 options.my.meta.uptime_kuma = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 description = "NMS metadata for uptime-kuma module";
 };


 config = lib.mkIf config.my.services.uptimeKuma.enable {
 services.uptime-kuma = { enable = true; settings.PORT = toString port; };
 services.caddy.virtualHosts."status.${domain}" = {
 extraConfig = "import family_auth\nreverse_proxy 127.0.0.1:${toString port}";
 };
 systemd.services.uptime-kuma.serviceConfig = {
 ProtectSystem = "strict"; ProtectHome = true; PrivateTmp = true; PrivateDevices = true; NoNewPrivileges = true;
 CapabilityBoundingSet = [ "CAP_NET_RAW" ]; AmbientCapabilities = [ "CAP_NET_RAW" ];
 MemoryMax = "512M"; CPUWeight = 30; OOMScoreAdjust = 500;
 };
 };
}
