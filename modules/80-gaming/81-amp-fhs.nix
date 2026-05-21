# ---NIXMETA
# ---
# domain: 80
# id: "NIXH-80-GAM-002"
# title: "AMP FHS Sandbox"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [gaming,amp,fhs]
# description: "FHS sandbox package for AMP."
# path: "modules/80-gaming/81-amp-fhs.nix"
# provides: [my.gaming.ampFhs]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/80-gaming/81-amp-fhs.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
{
  options.my.gaming.ampFhs = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
  };

  config = lib.mkIf config.my.gaming.ampFhs.enable {
    environment.systemPackages = [
      (pkgs.buildFHSEnv {
        name = "amp-fhs";
        targetPkgs = pkgs: with pkgs; [ dotnet-sdk_8 glibc openssl curl libicu sqlite screen bash ];
        runScript = "bash";
      })
    ];
  };
}
