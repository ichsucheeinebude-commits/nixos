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
 id = "NIXH-40-MED-010";
 title = "Media Stack Activation";
 description = "Central toggle for activating the entire media stack and its default profiles.";
 layer = 40;
 nixpkgs.category = "system/settings";
 capabilities = [ "system/media-activation" ];
 audit.last_reviewed = "2026-03-02";
 audit.complexity = 1;
 };
in
{
 options.my.meta.service_media_media_stack = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 description = "NMS metadata for service-media-media-stack module";
 };

 config = {
 my.media = {
 defaults.domain = config.my.configs.identity.domain;
 defaults.netns = "media-vault";
 jellyfin.enable = true;
 sonarr.enable = true;
 radarr.enable = true;
 readarr.enable = true;
 prowlarr.enable = true;
 sabnzbd.enable = true;
 jellyseerr.enable = true;
 };
 };
}
