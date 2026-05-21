# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-004"
# title: "Hardware Profile"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [core,hardware,cpu,gpu,microcode]
# description: "CPU microcode, GPU drivers, and hardware-specific configuration."
# path: "modules/00-core/03-hardware-profile.nix"
# provides: [my.core.hardware]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/00-core/03-hardware-profile.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.my.core.principles.enable (let
    cpu = config.my.core.hardware.cpuType;
    intelGpu = config.my.core.hardware.intelGpu;
  in lib.mkMerge [
    (lib.mkIf (cpu == "intel") { hardware.cpu.intel.updateMicrocode = lib.mkDefault true; })
    (lib.mkIf (cpu == "amd")   { hardware.cpu.amd.updateMicrocode = lib.mkDefault true; })
    (lib.mkIf intelGpu {
      hardware.graphics = {
        enable = lib.mkDefault true;
        extraPackages = lib.mkDefault [ pkgs.intel-media-driver pkgs.intel-compute-runtime ];
        enable32Bit = lib.mkDefault true;
      };
    })
  ]);
}
