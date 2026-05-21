# modules/40-media/44-streaming.nix
#
# Domain 40 – Streaming Layer
{ config, lib, pkgs, myLib, mediaLib, ... }:

let
  cfg = config.my.media.streaming;
in {
  imports = [ ./41-lib-media.nix ];

  options.my.media.streaming = {
    enable = lib.mkEnableOption "Media Streaming Stack (Jellyfin, Audiobookshelf, Navidrome)";
    gpuAcceleration = lib.mkEnableOption "Intel VAAPI / QSV hardware transcoding" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics.enable = lib.mkIf cfg.gpuAcceleration true;

    # Jellyfin Library Scan Schedule (manuell im Web-UI einzurichten)
    # Empfehlung: Scan täglich um 02:00 Uhr ("0 2 * * *")
    # Hintergrund: HDDs sind zu dieser Zeit idealerweise bereits aktiv (Backups, Mover) oder können gezielt aufgeweckt werden.
    # So wird vermieden, dass die Platten tagsüber wegen eines Scans aufwachen.
    # Quelle: https://jellyfin.org/docs/general/administration/configuration/#scan-schedule
    services.jellyfin        = { enable = true; dataDir = "/var/lib/jellyfin"; };
    services.audiobookshelf  = { enable = true; dataDir = "/var/lib/audiobookshelf"; port = 13378; };
    services.navidrome       = {
      enable   = true;
      settings = { MusicFolder = "/mnt/media/music"; Port = 4533; };
    };

    systemd.services.jellyfin.serviceConfig = lib.mkIf cfg.gpuAcceleration {
      DeviceAllow   = [ "char-render" "char-drm" ];
      ReadWritePaths = [ "/dev/dri" "/var/cache/jellyfin" ];
      SupplementaryGroups = [ "render" "video" ];
    };

    my.impermanence.directories = [
      "/var/lib/jellyfin"
      "/var/cache/jellyfin"
      "/var/lib/audiobookshelf"
      "/var/lib/navidrome"
    ];
  };
}
