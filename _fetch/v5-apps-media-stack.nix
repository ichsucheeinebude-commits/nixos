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
 id = "NIXH-40-MED-001";
 title = "Media Stack (Exhausted Layout)";
 description = "Canonical data/state layout with ABC-tiering enforcement and global media permissions.";
 layer = 40;
 nixpkgs.category = "system/storage";
 capabilities = [ "storage/layout" "security/permissions" ];
 audit.last_reviewed = "2026-03-02";
 audit.complexity = 2;
 };

 srePaths = config.my.configs.paths;
in
{
 options.my.meta.media_stack = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 description = "NMS metadata for media-stack module";
 };


 config = lib.mkIf config.my.services.mediaStack.enable {
 users.groups.media = { gid = 169; };
 users.groups.media.members = [ "jellyfin" "sabnzbd" "audiobookshelf" "sonarr" "radarr" "lidarr" "readarr" "prowlarr" "navidrome" ];
 systemd.tmpfiles.rules = [
 "d ${srePaths.mediaLibrary} 0775 root media -"
 "d ${srePaths.mediaLibrary}/movies 0775 radarr media -"
 "d ${srePaths.mediaLibrary}/tv 0775 sonarr media -"
 "d ${srePaths.mediaLibrary}/music 0775 lidarr media -"
 "d ${srePaths.mediaLibrary}/books 0775 readarr media -"
 "d ${srePaths.mediaLibrary}/documents 0775 paperless media -"
 
 # Tier B: Active Downloads (Buffer B3)
 "d ${srePaths.downloads} 0775 root media -"
 "d ${srePaths.downloads}/torrents 0775 prowlarr media -"
 "d ${srePaths.downloads}/usenet 0775 sabnzbd media -"
 "d ${srePaths.downloads}/incomplete 0775 root media -"
 
 # Tier C: Archive (Exclusive for cold downloads/overflow)
 "d ${srePaths.tierC}/archive 0775 root media -"
 "d ${srePaths.tierC}/archive/downloads 0775 root media -"

 # Core State
 "d ${srePaths.stateDir} 0755 root root -"
 "d ${srePaths.appCache} 0775 root media -"
 ];
 };
}
