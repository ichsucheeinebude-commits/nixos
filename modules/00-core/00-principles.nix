# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-001"
# title: "Principles & Defaults"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [core,principles,bastelmodus]
# description: "Global toggle and experimental flag for the entire boilerplate."
# path: "modules/00-core/00-principles.nix"
# provides: [my.core.principles]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/00-core/00-principles.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.core.principles = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Master toggle for all core boilerplate options.";
    };
    bastelmodus = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Experimental playground flag. When false, strict policies are enforced.";
    };
  };
}
