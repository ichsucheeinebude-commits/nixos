# ---NIXMETA
# ---
# domain: 70
# id: "NIXH-70-FRG-001"
# title: "Forgejo Git"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [forgejo, git]
# description: "Forgejo Git module."
# path: "modules/70-forge/70-forgejo.nix"
# provides: [my.forge.forgejo]
# requires: [10-network/10-network]
# links:
#   adr: docs/adr/ADR-70-forgejo.md
#   guide: docs/guides/70-forgejo.md
#   module: modules/70-forge/70-forgejo.nix
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
  name = "forgejo";
  cfg = config.my.services.forgejo;
in {
  options.my.services.forgejo = {
    enable = lib.mkEnableOption "Forgejo Sovereign Git";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (config.myLib.mkService {
      inherit config name;
      description = "Forgejo Git Service (Hardened)";
      port = config.my.ports.forgejo;
      # Forgejo needs some write access to its data directory which mkService provides.
      # We use SQLite3 to keep it lean.
    })
    {
      services.forgejo = {
        enable = true;
        database.type = "sqlite3";
        settings = {
          server = {
            DOMAIN = "git.${config.my.configs.identity.domain}";
            HTTP_ADDR = "127.0.0.1";
            HTTP_PORT = config.my.ports.forgejo;
            ROOT_URL = "https://git.${config.my.configs.identity.domain}/";
          };
          service.DISABLE_REGISTRATION = true;
          session.COOKIE_SECURE = true;
        };
        dump.enable = true;
      };

      systemd.services.forgejo.serviceConfig = {
        MemoryMax = "1G";
        MemoryHigh = "800M";
      };
    }
  ]);
}
