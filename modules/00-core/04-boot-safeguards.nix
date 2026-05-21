# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-005"
# title: "Boot Safeguards"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [core,boot,memtest,safeguards]
# description: "Boot configuration limits, memtest entry, and generation pruning."
# path: "modules/00-core/04-boot-safeguards.nix"
# provides: [my.core.boot]
# requires: []
# links:
#   adr: docs/adr/ADR-00-005-005.md
#   guide: docs/guides/GUIDE-00-005-005.md
#   module: modules/00-core/04-boot-safeguards.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
{
  options.my.core.boot = {
    configurationLimit = lib.mkOption { type = lib.types.int; default = 5; description = "Max boot generations to keep."; };
    memtest = lib.mkOption { type = lib.types.bool; default = true; description = "Include memtest86+ in boot menu."; };
  };

  config = lib.mkIf config.my.core.principles.enable {
    boot.loader.systemd-boot.configurationLimit = config.my.core.boot.configurationLimit;
    boot.loader.systemd-boot.memtest86.enable = config.my.core.boot.memtest;
  };
}

