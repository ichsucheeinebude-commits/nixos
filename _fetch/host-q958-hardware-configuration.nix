{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  nms = {
    id = "NIXH-00-COR-014";
    title = "Host Q958 Hardware Configuration";
    description = "Specific hardware configuration for the Fujitsu Esprimo Q958 SFF Server.";
    layer = 00;
    nixpkgs.category = "system/boot";
    capabilities = ["system/hardware" "hardware/q958"];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 1;
  };
in {
  options.my.meta.host_q958_hardware_configuration = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  config = {
    boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-intel"];
    boot.extraModulePackages = [];
    fileSystems."/" = {
      device = "/dev/disk/by-uuid/8d1d5128-6413-4b5b-bd96-e55851ae5dc2";
      fsType = "ext4";
    };
    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/B413-DB53";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
    swapDevices = [];
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
