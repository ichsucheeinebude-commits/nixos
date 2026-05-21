# modules/40-media/43-download.nix
#
# Domain 40 – Download Layer (SABnzbd + Recyclarr)
{ config, lib, pkgs, myLib, ... }:

let
  cfg = config.my.media.downloads;
in {
  options.my.media.downloads = {
    enable = lib.mkEnableOption "Media Download Stack (SABnzbd + Recyclarr)";
  };

  config = lib.mkIf cfg.enable {
    services.sabnzbd = {
      enable  = true;
      user    = "sabnzbd";
      group   = "media";
    };

    # Recyclarr for automated quality profiles
    services.recyclarr = {
      enable = true;
    };

    # Outbound nftables rules for SABnzbd (NNTP ports 119, 563)
    # networking.nftables.rules = ... (Placeholder for actual nftables integration)

    my.impermanence.directories = [ "/var/lib/sabnzbd" ];
  };
}
