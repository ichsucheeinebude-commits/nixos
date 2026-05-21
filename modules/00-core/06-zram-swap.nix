# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-007"
# title: "ZRAM Swap"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [core,zram,swap,memory]
# description: "Compressed RAM swap via zram."
# path: "modules/00-core/06-zram-swap.nix"
# provides: [my.core.zram]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/GUIDE-placeholder.md
#   module: modules/00-core/06-zram-swap.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.core.zram = {
    enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable zram swap."; };
    algorithm = lib.mkOption { type = lib.types.str; default = "zstd"; description = "Compression algorithm."; };
    memoryPercent = lib.mkOption { type = lib.types.int; default = 25; description = "Percentage of RAM for zram."; };
  };

  config = lib.mkIf (config.my.core.principles.enable && config.my.core.zram.enable) {
    zramSwap = {
      enable = true;
      algorithm = config.my.core.zram.algorithm;
      memoryPercent = config.my.core.zram.memoryPercent;
    };
  };
}

