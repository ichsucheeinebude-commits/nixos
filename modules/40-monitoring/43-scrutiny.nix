# ---NIXMETA
# ---
# domain: 40
# id: "NIXH-40-SCR-001"
# title: "Scrutiny SMART Monitor"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [scrutiny, smart]
# description: "Scrutiny SMART Monitor module."
# path: "modules/40-monitoring/43-scrutiny.nix"
# provides: [my.monitoring.scrutiny]
# requires: [30-storage/30-storage]
# links:
#   adr: docs/adr/ADR-40-scrutiny.md
#   guide: docs/guides/40-scrutiny.md
#   module: modules/40-monitoring/43-scrutiny.nix
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

{ config, lib, pkgs, ... }:
let
 
 port = config.my.ports.scrutiny;
 domain = config.my.configs.identity.domain;
in
{
 options.my.meta.scrutiny = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 description = "NMS metadata for scrutiny module";
 };


 config = lib.mkIf config.my.services.scrutiny.enable {
 services.scrutiny = { enable = true; settings = { web.listen.port = port; web.listen.host = "127.0.0.1"; log.level = "INFO"; }; influxdb.enable = true; collector = { enable = true; schedule = "daily"; }; };
 services.caddy.virtualHosts."scrutiny.${domain}" = { extraConfig = "import family_auth\nreverse_proxy 127.0.0.1:${toString port}"; };
 systemd.services.scrutiny.serviceConfig = { DynamicUser = true; ProtectSystem = "strict"; ProtectHome = true; PrivateTmp = true; PrivateDevices = true; OOMScoreAdjust = 800; };
 services.smartd.enable = true;
 };
}
