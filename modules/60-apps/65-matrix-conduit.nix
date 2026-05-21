# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-006"
# title: "Matrix Conduit"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [apps,matrix,conduit,chat]
# description: "Matrix Conduit homeserver."
# path: "modules/60-apps/65-matrix-conduit.nix"
# provides: [my.apps.matrixConduit]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/60-apps/65-matrix-conduit.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
let
  idCfg = config.my.core.identity;
  serverName = "matrix." + idCfg.subdomain + "." + idCfg.domain;
in
{
  options.my.apps.matrixConduit = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 6167; };
    allowRegistration = lib.mkOption { type = lib.types.bool; default = false; };
  };

  config = lib.mkIf config.my.apps.matrixConduit.enable {
    services.matrix-conduit = {
      enable = true;
      settings.global = {
        server_name = lib.mkIf (idCfg.domain != "") serverName;
        port = config.my.apps.matrixConduit.port;
        address = "127.0.0.1";
        database_backend = "rocksdb";
        allow_registration = config.my.apps.matrixConduit.allowRegistration;
      };
    };
  };
}
