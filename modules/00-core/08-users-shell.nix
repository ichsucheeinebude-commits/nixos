# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-009"
# title: "Users & Groups"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [core,users,groups]
# description: "System user and group definitions (no shell aliases)."
# path: "modules/00-core/08-users-shell.nix"
# provides: [my.core.users]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/00-core/08-users-shell.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.core.users = {
    list = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption { type = lib.types.str; description = "Username."; };
          isNormalUser = lib.mkOption { type = lib.types.bool; default = true; };
          extraGroups = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
          openssh.authorizedKeys.keys = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "SSH public keys."; };
          shell = lib.mkOption { type = lib.types.package; default = null; };
        };
      });
      default = [];
      description = "List of users to create.";
    };
  };

  config = lib.mkIf (config.my.core.principles.enable && config.my.core.users.list != []) {
    users.users = lib.mkMerge (map (u: {
      ${u.name} = {
        inherit (u) isNormalUser;
        extraGroups = u.extraGroups;
        inherit (u) shell;
        openssh.authorizedKeys.keys = u.openssh.authorizedKeys.keys;
      };
    }) config.my.core.users.list);
  };
}
