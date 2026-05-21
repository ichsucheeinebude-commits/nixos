{
  config,
  lib,
  pkgs,
  ...
}: let
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-00-COR-017";
    title = "Kernel Slim (Hardened)";
    description = "Optimized and hardened kernel for Q958 by blacklisting unused modules and tuning sysctl.";
    layer = 00;
    nixpkgs.category = "system/boot";
    capabilities = ["kernel/hardening" "system/performance" "security/sysctl"];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 3;
  };

  cfg = config.my.profiles.hardware.q958;

  ramBenchmark = pkgs.writeShellScriptBin "ram-benchmark" ''
    #!/usr/bin/env bash
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔬 Kernel RAM-Footprint Analyse"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    TOTAL=$(free -m | awk 'NR==2 {print $2}')
    USED=$(free -m | awk 'NR==2 {print $3}')
    echo "Gesamt-RAM:   ''${TOTAL} MB"
    echo "Verwendet:    ''${USED} MB"
    MODULES=$(lsmod | wc -l)
    echo "Geladene Module: $((MODULES - 1))"
  '';
in {
  options.my.meta.kernel_slim = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for kernel-slim module";
  };

  config = lib.mkIf (config.my.services.kernelSlim.enable && cfg.enable) {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    # 🛡️ MODULE BLACKLIST (Reduced Attack Surface)
    boot.blacklistedKernelModules = [
      "bluetooth"
      "btusb"
      "btrtl"
      "btbcm"
      "btintel"
      "bnep"
      "rfcomm"
      "iwlwifi"
      "ath9k"
      "ath10k_core"
      "ath10k_pci"
      "rtl8192ce"
      "rtl8192cu"
      "rtl8192de"
      "rtl8188ee"
      "mt76"
      "brcmfmac"
      "brcmutil"
      "nouveau"
      "radeon"
      "amdgpu"
      "mgag200"
      "ast"
      "pcspkr"
      "iTCO_wdt"
      "iTCO_vendor_support"
      "thunderbolt"
    ];

    hardware.enableRedistributableFirmware = lib.mkForce false;
    hardware.firmware = lib.mkForce [pkgs.linux-firmware];

    # 🏎️ KERNEL SYSCTL HARDENING (Aviation Grade)
    boot.kernel.sysctl = {
      # IPv4 Stack
      "net.ipv4.conf.all.rp_filter" = lib.mkForce 1;
      "net.ipv4.conf.default.rp_filter" = lib.mkForce 1;
      "net.ipv4.tcp_syncookies" = lib.mkForce 1;
      "net.ipv4.tcp_rfc1323" = 1;
      "net.ipv4.tcp_sack" = 1;
      "net.ipv4.tcp_fastopen" = 3;

      # Security & Integrity
      "kernel.kptr_restrict" = lib.mkForce 2;
      "kernel.dmesg_restrict" = lib.mkForce 1;
      "kernel.unprivileged_bpf_disabled" = 1; # 💎 Essential Hardening
      "kernel.perf_event_paranoid" = 3;

      # Memory & Performance
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 50;
      "kernel.shmmax" = 1073741824; # 1GB Shm for AI/DB
    };

    boot.initrd.availableKernelModules = lib.mkForce ["ahci" "sd_mod" "xhci_pci" "usbhid" "usb_storage"];

    environment.systemPackages = with pkgs; [
      linuxPackages_latest.perf
      ramBenchmark
      kmod
      pciutils
      usbutils
    ];
    programs.bash.shellAliases = {ram-bench = "${ramBenchmark}/bin/ram-benchmark";};

    boot.kernelParams = ["quiet" "loglevel=3" "systemd.show_status=auto" "rd.udev.log_level=3" "logo.nologo"];

    systemd.services.kernel-slim-info = {
      description = "Kernel Slim Info Banner";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        logger -t kernel-slim "Optimized kernel loaded (Q958 profile)"
        MODULES=$(lsmod | wc -l)
        logger -t kernel-slim "Loaded modules: $((MODULES - 1))"
      '';
    };
  };
}
/**
* ---
 * technical_integrity:
 *   checksum: sha256:8757415fb158e6673a10c5aee208112b7d339f8f014e2c90e9a3e6c8ff51e319
 *   eof_marker: NIXHOME_VALID_EOF* ---
*/

