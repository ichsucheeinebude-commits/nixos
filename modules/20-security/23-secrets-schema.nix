# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SEC-004"
# title: "Secrets Schema"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [security,sops,schema]
# description: "Declarative schema for SOPS secret definitions."
# path: "modules/20-security/23-secrets-schema.nix"
# provides: [my.security.secretsSchema]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/20-security/23-secrets-schema.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.security.secretsSchema = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    schema = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = {};
    };
  };

  config = lib.mkIf config.my.security.secretsSchema.enable {
    assertions = lib.mapAttrsToList (name: def: {
      assertion = config.sops.secrets ? ${name} || def.optional or false;
      message = "Missing required secret: ${name}";
    }) config.my.security.secretsSchema.schema;
  };
}
