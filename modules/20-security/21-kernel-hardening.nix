# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SEC-002"
# title: "Kernel Hardening"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [security,kernel,sysctl]
# description: "Kernel module blacklist, sysctl hardening, boot parameters."
# path: "modules/20-security/21-kernel-hardening.nix"
# provides: [my.security.kernel]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/20-security/21-kernel-hardening.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
{
  options.my.security.kernel = {
    enable = lib.mkOption { type = lib.types.bool; default = true; };
    lockModules = lib.mkOption { type = lib.types.bool; default = true; };
    apparmor = lib.mkOption { type = lib.types.bool; default = true; };
    blacklistModules = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
  };

  config = lib.mkIf config.my.security.kernel.enable {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    boot.blacklistedKernelModules = [
      "snd_hda_intel" "snd_hda_codec_realtek"
      "iwlwifi" "ath9k" "ath10k_core"
      "bluetooth" "btusb"
      "nouveau" "radeon" "amdgpu"
      "dccp" "sctp" "rds" "tipc"
    ] ++ config.my.security.kernel.blacklistModules;
    boot.kernel.sysctl = {
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
      "kernel.unprivileged_userns_clone" = 0;
      "fs.protected_hardlinks" = 1;
      "fs.protected_symlinks" = 1;
      "vm.mmap_rnd_bits" = 32;
    };
    security.lockKernelModules = config.my.security.kernel.lockModules;
    security.apparmor.enable = config.my.security.kernel.apparmor;
    boot.kernelParams = [
      "mitigations=auto,nosmt"
      "slab_nomerge"
      "init_on_free=1"
      "vsyscall=none"
      "debugfs=off"
      "lockdown=integrity"
    ];
  };
}
