# ---NIXMETA
# ---
# domain: 30
# id: "NIXH-30-STO-004"
# title: "Storage Policy"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [storage,policy,assertions]
# description: "Storage tiering policy assertions."
# path: "modules/30-storage/33-storage-policy.nix"
# provides: [my.storage.policy]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/30-storage/33-storage-policy.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.storage.policy = {
    enable = lib.mkOption { type = lib.types.bool; default = true; };
  };

  config = lib.mkIf config.my.storage.policy.enable {
    assertions = [
      {
        assertion = config.my.storage.tierA == "/persist";
        message = "ABC Tiering Error: Tier A MUST be /persist.";
      }
    ];
  };
}
