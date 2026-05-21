# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-DIS-001"
# title: "Media Discovery"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [discovery, jellyseerr]
# description: "Media Discovery module."
# path: "modules/50-media/54-discovery.nix"
# provides: [my.media.discovery]
# requires: [50-media/51-arr-stack]
# links:
#   adr: docs/adr/ADR-50-discovery.md
#   guide: docs/guides/50-discovery.md
#   module: modules/50-media/54-discovery.nix
# ---
# ---ENDNIXMETA

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
