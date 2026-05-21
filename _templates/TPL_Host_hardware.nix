# Hardware configuration template (nixos-generate-config output)
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # TODO: Replace with actual disk UUIDs
  # fileSystems."/boot" = { device = "/dev/disk/by-uuid/XXXX"; fsType = "vfat"; };
  # fileSystems."/"     = { device = "/dev/disk/by-uuid/XXXX"; fsType = "ext4"; };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
