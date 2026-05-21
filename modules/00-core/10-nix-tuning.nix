# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-024"
# title: "Nix Tuning"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [nix,tuning,binary-cache,gc,auto-optimise]
# description: "Binary cache enforcement, nix-daemon tuning, auto GC, and store optimization."
# path: "modules/00-core/10-nix-tuning.nix"
# provides: [my.nixTuning]
# requires: []
# links:
#   module: modules/00-core/10-nix-tuning.nix
# source: _meta/00-core/nix-tuning.nix (NIXH-00-COR-024)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
{
  options.my.nixTuning.enable = lib.mkEnableOption "Nix tuning (binary-only, auto-gc)";

  config = lib.mkIf config.my.nixTuning.enable {
    nix.settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      max-jobs = lib.mkForce 0;
      connect-timeout = 5;
      builders-use-substitutes = true;
      auto-optimise-store = true;
      narinfo-cache-negative-ttl = 0;
      timeout = 1800;
      experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" "cgroups" ];
      sandbox = true;
      trusted-users = [ "root" "@wheel" ];
    };

    nix.daemonCPUSchedPolicy = "idle";
    nix.daemonIOSchedClass = "idle";

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
      persistent = true;
    };

    environment.systemPackages = with pkgs; [
      cachix nix-tree nix-diff nix-output-monitor nixfmt-classic
    ];
  };
}
