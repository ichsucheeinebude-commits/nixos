# ---NIXMETA
# ---
# domain: 30
# id: "NIXH-30-STO-003"
# title: "Impermanence"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [storage,impermanence,stateless]
# description: "Stateless root with /persist persistence."
# path: "modules/30-storage/32-impermanence.nix"
# provides: [my.storage.impermanence]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/30-storage/32-impermanence.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.storage.impermanence = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    persistDir = lib.mkOption { type = lib.types.str; default = "/persist"; };
    directories = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
    files = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
    ramfsSize = lib.mkOption { type = lib.types.str; default = "4G"; };
  };

  config = lib.mkIf config.my.storage.impermanence.enable {
    fileSystems."/" = lib.mkForce {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=${config.my.storage.impermanence.ramfsSize}" "mode=755" ];
    };
  };
}
