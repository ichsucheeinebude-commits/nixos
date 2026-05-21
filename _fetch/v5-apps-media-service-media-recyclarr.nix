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
 # 🚀 NMS v4.0 Metadaten
 nms = {
 id = "NIXH-40-MED-014";
 title = "Recyclarr (SRE Declarative)";
 description = "Declarative management of Radarr/Sonarr quality profiles and custom formats.";
 layer = 40;
 nixpkgs.category = "services/misc";
 capabilities = [ "media/quality-profiles" "automation/declarative-config" ];
 audit.last_reviewed = "2026-03-02";
 audit.complexity = 2;
 };
in
{
 options.my.meta.recyclarr = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 description = "NMS metadata for recyclarr module";
 };


 config = lib.mkIf config.my.services.recyclarr.enable {
 services.recyclarr = {
 enable = true;
 configuration = {
 sonarr.tv = { base_url = "https://sonarr.${config.my.configs.identity.domain}"; api_key = "!env_var SONARR_API_KEY"; include = [ { template = "v3-sonarr-web-dl-1080p-v2-remux-720p"; } ]; };
 radarr.movies = { base_url = "https://radarr.${config.my.configs.identity.domain}"; api_key = "!env_var RADARR_API_KEY"; include = [ { template = "v3-radarr-web-dl-1080p-v2-remux-720p"; } ]; };
 };
 };
 systemd.services.recyclarr.serviceConfig = {
 LoadCredential = [ "sonarr_api:${config.sops.secrets.sonarr_api_key.path}" "radarr_api:${config.sops.secrets.radarr_api_key.path}" ];
 Environment = [ "SONARR_API_KEY_FILE=/run/credentials/recyclarr.service/sonarr_api" "RADARR_API_KEY_FILE=/run/credentials/recyclarr.service/radarr_api" ];
 ProtectSystem = "strict"; PrivateTmp = true; NoNewPrivileges = true; MemoryMax = "512M"; OOMScoreAdjust = 1000;
 };
 };
}
