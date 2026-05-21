# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SEC-003"
# title: "Kernel Hardening"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-21
# tags: [security,kernel,hardening,sysctl,boot]
# description: "Kernel hardening with sysctl, boot parameters, and module restrictions from KB security baseline."
# path: "modules/20-security/21-kernel-hardening.nix"
# provides: [my.security.kernel-hardening]
# requires: [00-core]
# links:
#   adr: docs/adr/ADR-21-kernel-hardening.md
#   guide: docs/guides/21-kernel-hardening.md
#   module: modules/20-security/21-kernel-hardening.nix
# source: services/security-hardening-baseline.md
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
let
  cfg = config.my.security.kernel-hardening;
in
{
  options.my.security.kernel-hardening = {
    enable = lib.mkEnableOption "Kernel hardening with sysctl and boot parameter restrictions";

    # ── Network Hardening ──
    disableIpv6 = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Disable IPv6 stack entirely.";
    };
    disableSourceRouting = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable source routing (prevents IP spoofing).";
    };
    disableIcmpRedirects = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable ICMP redirects (prevents MITM attacks).";
    };
    disableIcmpAccept = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable accepting ICMP (prevent network discovery).";
    };
    enableSynCookies = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable SYN cookies (protect against SYN flood).";
    };
    disableIpForwarding = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable IP forwarding (unless acting as router).";
    };
    logMartians = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Log Martian packets (spoofed source addresses).";
    };
    rpFilter = lib.mkOption {
      type = lib.types.enum [ 0 1 2 ];
      default = 1;
      description = "Reverse path filtering mode (1 = strict, 2 = loose).";
    };

    # ── Memory Hardening ──
    restrictDmesg = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Restrict dmesg access to root only.";
    };
    restrictKptr = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Hide kernel pointers from non-root users.";
    };
    kernelPtraceScope = lib.mkOption {
      type = lib.types.enum [ 0 1 2 ];
      default = 1;
      description = "ptrace scope (1 = only parent processes).";
    };
    disableSysrq = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable SysRq key (prevents local attacks).";
    };
    mlockLimit = lib.mkOption {
      type = lib.types.int;
      default = 65536;
      description = "Maximum locked memory size in KB.";
    };

    # ── Filesystem Hardening ──
    disableCoreDumps = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable core dumps.";
    };
    hardlinkProtection = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Protect hard links (prevent cross-UID linking).";
    };
    symlinkProtection = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Protect symlinks in sticky directories.";
    };

    # ── Boot Parameters ──
    extraBootParams = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional kernel boot parameters.";
    };
    enableSlubHardening = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable SLUB allocator hardening.";
    };
    enablePagePoisoning = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable page poisoning (detect use-after-free).";
    };

    # ── Module Restrictions ──
    disabledKernelModules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "cramfs" "freevxfs" "jffs2" "hfs" "hfsplus" "squashfs" "udf" "vfat" ];
      description = "Kernel modules to blacklist.";
    };

    # ── CIS Benchmark ──
    cisLevel = lib.mkOption {
      type = lib.types.enum [ 1 2 ];
      default = 1;
      description = "CIS Benchmark level (1 = essential, 2 = defense-in-depth).";
    };
  };

  config = lib.mkIf cfg.enable {
    # ── Sysctl Hardening ──
    boot.kernel.sysctl = {
      # Network
      "net.ipv6.conf.all.disable_ipv6" = cfg.disableIpv6;
      "net.ipv4.conf.all.accept_source_route" = if cfg.disableSourceRouting then 0 else 1;
      "net.ipv4.conf.default.accept_source_route" = if cfg.disableSourceRouting then 0 else 1;
      "net.ipv4.conf.all.accept_redirects" = if cfg.disableIcmpRedirects then 0 else 1;
      "net.ipv4.conf.default.accept_redirects" = if cfg.disableIcmpRedirects then 0 else 1;
      "net.ipv4.conf.all.send_redirects" = if cfg.disableIcmpRedirects then 0 else 1;
      "net.ipv4.icmp_echo_ignore_all" = if cfg.disableIcmpAccept then 1 else 0;
      "net.ipv4.tcp_syncookies" = if cfg.enableSynCookies then 1 else 0;
      "net.ipv4.ip_forward" = if cfg.disableIpForwarding then 0 else 1;
      "net.ipv4.conf.all.log_martians" = if cfg.logMartians then 1 else 0;
      "net.ipv4.conf.default.log_martians" = if cfg.logMartians then 1 else 0;
      "net.ipv4.conf.all.rp_filter" = cfg.rpFilter;
      "net.ipv4.conf.default.rp_filter" = cfg.rpFilter;

      # Memory
      "kernel.dmesg_restrict" = if cfg.restrictDmesg then 1 else 0;
      "kernel.kptr_restrict" = if cfg.restrictKptr then 2 else 0;
      "kernel.yama.ptrace_scope" = cfg.kernelPtraceScope;
      "kernel.sysrq" = if cfg.disableSysrq then 0 else 1;
      "vm.mmap_rnd_bits" = 32;

      # Filesystem
      "fs.protected_hardlinks" = if cfg.hardlinkProtection then 1 else 0;
      "fs.protected_symlinks" = if cfg.symlinkProtection then 1 else 0;
    };

    # ── Boot Parameters ──
    boot.kernelParams = [
      "slab_nomerge"
      "init_on_alloc=1"
      "init_on_free=1"
    ] ++ lib.optionals cfg.enableSlubHardening [
      "slub_debug=P"
    ] ++ lib.optionals cfg.enablePagePoisoning [
      "page_poison=1"
    ] ++ lib.optionals cfg.cisLevel >= 2 [
      "lockdown=confidentiality"
    ] ++ cfg.extraBootParams;

    # ── Module Blacklisting ──
    boot.blacklistedKernelModules = cfg.disabledKernelModules;

    # ── Core Dumps ──
    security.pam.loginLimits = lib.mkIf cfg.disableCoreDumps [
      {
        domain = "*";
        type = "hard";
        item = "core";
        value = "0";
      }
    ];
  };
}
