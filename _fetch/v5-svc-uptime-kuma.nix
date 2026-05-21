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
 id = "NIXH-80-MON-004";
 title = "Uptime Kuma (SRE Exhausted)";
 description = "Self-hosted monitoring tool, tightly sandboxed with resource limits.";
 layer = 80;
 nixpkgs.category = "services/monitoring";
 capabilities = [ "monitoring/uptime" "web/dashboard" ];
 audit.last_reviewed = "2026-03-02";
 audit.complexity = 1;
 };

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
