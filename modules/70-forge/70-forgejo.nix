# ---NIXMETA
# ---
# domain: 70
# id: "NIXH-70-FRG-001"
# title: "Forgejo Git"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [forge,forgejo,git]
# description: "Forgejo self-hosted Git service."
# path: "modules/70-forge/70-forgejo.nix"
# provides: [my.forge.forgejo]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/70-forge/70-forgejo.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.forge.forgejo = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 3000; };
    disableRegistration = lib.mkOption { type = lib.types.bool; default = true; };
  };

  config = lib.mkIf config.my.forge.forgejo.enable {
    services.forgejo = {
      enable = true;
      database.type = "sqlite3";
      settings = {
        server = {
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = config.my.forge.forgejo.port;
        };
        service.DISABLE_REGISTRATION = config.my.forge.forgejo.disableRegistration;
      };
    };
  };
}
