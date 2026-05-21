# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-003"
# title: "Vaultwarden"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [apps,vaultwarden,passwords]
# description: "Vaultwarden password manager."
# path: "modules/60-apps/62-vaultwarden.nix"
# provides: [my.apps.vaultwarden]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/60-apps/62-vaultwarden.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.apps.vaultwarden = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 7277; };
    signupsAllowed = lib.mkOption { type = lib.types.bool; default = false; };
  };

  config = lib.mkIf config.my.apps.vaultwarden.enable {
    services.vaultwarden = {
      enable = true;
      config = {
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = config.my.apps.vaultwarden.port;
        SIGNUPS_ALLOWED = config.my.apps.vaultwarden.signupsAllowed;
      };
    };
  };
}
