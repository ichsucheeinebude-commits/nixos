# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-074"
# title: "Read Me A Book"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-22
# tags: [apps,audiobooks,readmeabook,streaming]
# description: "Self-hosted audiobook reader and manager (alternative to Audiobookshelf). Reserves port and vhost mapping."
# path: "modules/60-apps/74-readmeabook.nix"
# provides: [my.media.readmeabook]
# requires: [00-core]
# links:
#   module: modules/60-apps/74-readmeabook.nix
# source: mynixos-v5/modules/apps/service-app-readmeabook.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:

let
  cfg = config.my.media.readmeabook;
  domain = config.my.core.identity.domain or "example.com";
  subdomain = config.my.core.identity.subdomain or "nix";
in
{
  # ── Read Me A Book ──
  # Self-hosted audiobook reader (alternative to ABS).
  # Currently reserves port and vhost; full service integration
  # requires manual package or container-based approach.

  options.my.media.readmeabook = {
    enable = lib.mkEnableOption "Read Me A Book audiobook reader";
    port = lib.mkOption {
      type = lib.types.port;
      default = config.my.ports.readmeabook or 20012;
      description = "Read Me A Book web UI port.";
    };
  };

  config = lib.mkIf cfg.enable {
    # ── Port and domain reservation ──
    # Note: Read Me A Book is not in nixpkgs yet.
    # Full service deployment requires manual package or container.

    # Reserve vhost mapping for when the service is fully configured
    services.caddy.virtualHosts."read.${subdomain}.${domain}" = {
      extraConfig = ''
        # TODO: Replace with actual Read Me A Book upstream
        # reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
