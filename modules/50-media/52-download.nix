# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-DWN-001"
# title: "Download Stack"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [download, usenet]
# description: "Download Stack module."
# path: "modules/50-media/52-download.nix"
# provides: [my.media.download]
# requires: [50-media/51-arr-stack]
# links:
#   adr: docs/adr/ADR-50-download.md
#   guide: docs/guides/50-download.md
#   module: modules/50-media/52-download.nix
# ---
# ---ENDNIXMETA

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
