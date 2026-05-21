# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-008"
# title: "Pocket-ID"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [network,oidc,auth,pocket-id]
# description: "Pocket-ID OIDC provider for SSO."
# path: "modules/10-network/17-pocket-id.nix"
# provides: [my.network.pocketId]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/10-network/17-pocket-id.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.network.pocketId = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    issuerUrl = lib.mkOption { type = lib.types.str; default = ""; };
  };

  config = lib.mkIf config.my.network.pocketId.enable {
    services.pocket-id = {
      enable = true;
      settings = {
        public_registration = false;
      };
    };
  };
}
