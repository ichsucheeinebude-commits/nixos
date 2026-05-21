# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-010"
# title: "PostgreSQL"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [core,postgresql,database]
# description: "PostgreSQL database service."
# path: "modules/00-core/09-postgresql.nix"
# provides: [my.core.postgresql]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/00-core/09-postgresql.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.core.postgresql = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable PostgreSQL."; };
    package = lib.mkOption { type = lib.types.package; default = null; };
  };

  config = lib.mkIf config.my.core.postgresql.enable {
    services.postgresql = {
      enable = true;
      package = lib.mkIf (config.my.core.postgresql.package != null) config.my.core.postgresql.package;
    };
    systemd.tmpfiles.rules = [ "d /run/postgresql 0755 postgres postgres -" ];
  };
}
