# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-003"
# title: "Nix Tuning"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [core,nix,gc,optimization]
# description: "Nix daemon tuning, GC settings, and build optimization."
# path: "modules/00-core/02-nix-tuning.nix"
# provides: [my.core.nix]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/GUIDE-placeholder.md
#   module: modules/00-core/02-nix-tuning.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.core.nix = {
    enable = lib.mkOption { type = lib.types.bool; default = true; description = "Apply nix tuning."; };
    gc.automatic = lib.mkOption { type = lib.types.bool; default = true; description = "Automatic garbage collection."; };
    gc.interval = lib.mkOption { type = lib.types.str; default = "weekly"; description = "GC schedule."; };
    gc.options = lib.mkOption { type = lib.types.str; default = "--delete-older-than 7d"; description = "GC options."; };
    optimise.automatic = lib.mkOption { type = lib.types.bool; default = true; description = "Automatic store optimisation."; };
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {
        auto-optimise-store = true;
        use-xdg-base-directories = true;
        experimental-features = [ "nix-command" "flakes" ];
        warn-dirty = false;
      };
      description = "Nix daemon settings.";
    };
  };

  config = lib.mkIf (config.my.core.principles.enable && config.my.core.nix.enable) {
    nix = {
      gc = {
        automatic = config.my.core.nix.gc.automatic;
        dates = config.my.core.nix.gc.interval;
        options = config.my.core.nix.gc.options;
      };
      settings = config.my.core.nix.settings;
    };
    nix.optimise = { automatic = config.my.core.nix.optimise.automatic; };
  };
}

