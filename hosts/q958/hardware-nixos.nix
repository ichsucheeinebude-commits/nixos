# ── Hardware Configuration (nixos-generate-config output) ──
# Replace with your actual hardware configuration
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # TODO: Replace with actual partition layout
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "ext4" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # TODO: Replace with actual disk UUIDs
  # fileSystems."/boot" = { device = "/dev/disk/by-uuid/XXXX-XXXX"; fsType = "vfat"; };
  # fileSystems."/"     = { device = "/dev/disk/by-uuid/XXXX-XXXX"; fsType = "ext4"; };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
