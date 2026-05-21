# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-063"
# title: "Seerr (Media Requests)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [media,seerr,jellyseerr,requests,sso]
# description: "Jellyseerr media request management for Jellyfin and Arr-stack. Configurable port with SSO support via the service factory."
# path:
# provides: [my.media.seerr]
# requires: [00-core]
# links:
#   module: modules/50-media/63-seerr.nix
# source: mynixos-v5/modules/apps/service-media-seerr.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:

let
  cfg = config.my.media.seerr;
in
{
  # ── Seerr (Jellyseerr) ──
  # Unified media request management for Jellyfin + Arr-stack.

  options.my.media.seerr = {
    enable = lib.mkEnableOption "Jellyseerr media requests";
    port = lib.mkOption {
      type = lib.types.port;
      default = config.my.ports.jellyseerr or 25055;
      description = "Jellyseerr web UI port.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.jellyseerr = {
      enable = true;
      port = cfg.port;
    };
  };
}
