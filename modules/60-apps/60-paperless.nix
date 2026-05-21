# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-001"
# title: "Paperless-ngx"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [apps,paperless,documents]
# description: "Paperless-ngx document management."
# path: "modules/60-apps/60-paperless.nix"
# provides: [my.apps.paperless]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/60-apps/60-paperless.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.apps.paperless = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 28981; };
    ocrLanguage = lib.mkOption { type = lib.types.str; default = "deu+eng"; };
  };

  config = lib.mkIf config.my.apps.paperless.enable {
    services.paperless = {
      enable = true;
      address = "127.0.0.1";
      port = config.my.apps.paperless.port;
    };
  };
}
