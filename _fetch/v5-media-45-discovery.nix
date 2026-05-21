# modules/40-media/45-discovery.nix
#
# Domain 40 – Discovery Layer (Jellyseerr)
{ config, lib, pkgs, myLib, ... }:

let
  cfg = config.my.media.discovery;
in {
  options.my.media.discovery = {
    enable = lib.mkEnableOption "Media Discovery Stack (Jellyseerr)";
  };

  config = lib.mkIf cfg.enable {
    services.jellyseerr = {
      enable = true;
      port   = 5055;
    };

    my.impermanence.directories = [ "/var/lib/jellyseerr" ];

    my.services.caddy.virtualHosts."requests.${config.my.domain}" = {
      upstream    = "http://127.0.0.1:5055";
      forwardAuth = true;
    };
  };
}
