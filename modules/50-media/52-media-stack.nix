# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-40-MED-001"
# title: "Media Stack (Exhausted Layout)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [media-stack,abc-tiering,tmpfiles,permissions,media-group]
# description: "Canonical media/state layout with ABC-tiering enforcement and global media permissions."
# path: "modules/50-media/52-media-stack.nix"
# provides: [my.media.stack]
# requires: [30-storage]
# links:
#   module: modules/50-media/52-media-stack.nix
# source: _meta/40-media/media-stack.nix (NIXH-40-MED-001)
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.media.stack;
  mediaLib = cfg.mediaLibrary;
  storagePool = cfg.storagePool;
  stateDir = cfg.stateDir;
in
{
  options.my.media.stack = {
    enable = lib.mkEnableOption "Media stack layout with ABC tiering";
    mediaLibrary = lib.mkOption { type = lib.types.str; default = "/mnt/media"; };
    storagePool = lib.mkOption { type = lib.types.str; default = "/mnt/fast-pool"; };
    stateDir = lib.mkOption { type = lib.types.str; default = "/data/state"; };
    mediaGid = lib.mkOption { type = lib.types.int; default = 169; description = "GID for media group."; };
  };

  config = lib.mkIf cfg.enable {
    users.groups.media = {
      gid = cfg.mediaGid;
      members = [ "jellyfin" "sabnzbd" "audiobookshelf" "sonarr" "radarr" "lidarr" "readarr" "prowlarr" ];
    };

    systemd.tmpfiles.rules = [
      "d ${mediaLib} 0775 root media -"
      "d ${mediaLib}/movies 0775 radarr media -"
      "d ${mediaLib}/tv 0775 sonarr media -"
      "d ${mediaLib}/music 0775 lidarr media -"
      "d ${mediaLib}/books 0775 readarr media -"
      "d ${mediaLib}/documents 0775 paperless media -"
      "d ${storagePool}/downloads 0775 root media -"
      "d ${storagePool}/downloads/torrents 0775 prowlarr media -"
      "d ${storagePool}/downloads/usenet 0775 sabnzbd media -"
      "d ${stateDir} 0755 root root -"
      "d ${storagePool}/metadata 0775 root media -"
      "d ${storagePool}/cache 0775 root media -"
    ];
  };
}
