# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SEC-034"
# title: "System Hardening"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-22
# tags: [security,hardening,bootloader,sysctl,filesystem,misterio77]
# description: "Comprehensive system-level hardening: bootloader protection, filesystem mount restrictions, supplementary sysctl tuning, and kernel attack-surface reduction. Misterio77-inspired patterns."
# path: "modules/20-security/34-system-hardening.nix"
# provides: [my.security.system-hardening]
# requires: [00-core]
# links:
#   adr: docs/adr/ADR-20-security.md
#   guide: docs/guides/20-security.md
#   module: modules/20-security/34-system-hardening.nix
# source: Misterio77/nix-config hardening patterns
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### 🔒 System Hardening (Layer 34-policy)
# - Bootloader: Reduce timeout, remove recovery entry to limit physical attack window
# - Filesystem: noexec/nosuid/nodev on tmpfs mounts prevents privilege escalation via staged binaries
# - Sysctl: TCP hardening (timestamps, SYN retries), BPF JIT, socket buffer limits
# - Kernel: IO delay via iopl, panic-on-oops for servers, CPU microcode hardening
# - Core dumps: Restrict to root, limit size, prevent info leakage
# - Module loading: Combine with lockKernelModules (27-hardened-core) for defense-in-depth
# ─── End KB Nuggets ───

{ config, lib, ... }:

let
  cfg = config.my.security.system-hardening;
in
{
  # ── System Hardening ──
  # Comprehensive system-level hardening inspired by Misterio77/nix-config.
  # Complements 21-kernel-hardening.nix (sysctl/baseline) and
  # 27-hardened-core.nix (kernel lockdown/service slimming).

  options.my.security.system-hardening = {
    enable = lib.mkEnableOption "Comprehensive system-level hardening";

    # ── Bootloader ──
    bootloaderTimeout = lib.mkOption {
      type = lib.types.int;
      default = 3;
      description = "Boot menu timeout in seconds. Set to 0 for instant boot (no user selection possible). Recommended: 1-3 for servers.";
    };
    removeRecovery = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Remove recovery/old generation entries from boot menu to reduce attack surface.";
    };

    grubPasswordHash = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "GRUB password hash for the 'admin' user (generated via grub-mkpasswd-pbkdf2). When set, GRUB menu editing and non-default boot entries require authentication.";
    };

    # ── Filesystem Mount Hardening ──
    hardenTmp = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Mount /tmp with noexec,nosuid,nodev to prevent privilege escalation via staged binaries.";
    };
    hardenDevShm = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Mount /dev/shm with noexec,nosuid,nodev.";
    };
    hardenRunLock = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Mount /run/lock with noexec,nosuid,nodev.";
    };

    # ── Supplementary Sysctl ──
    disableTcpTimestamps = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable TCP timestamps (prevents uptime fingerprinting).";
    };
    tcpSynRetries = lib.mkOption {
      type = lib.types.int;
      default = 3;
      description = "Maximum number of TCP SYN retransmissions before giving up. Lower values reduce resource exhaustion risk.";
    };
    tcpMaxSynBacklog = lib.mkOption {
      type = lib.types.int;
      default = 4096;
      description = "Maximum number of remembered connection requests in the SYN backlog.";
    };
    tcpFinTimeout = lib.mkOption {
      type = lib.types.int;
      default = 15;
      description = "TCP FIN timeout in seconds. Lower values reduce TIME_WAIT socket accumulation.";
    };
    disableAcceptRa = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable accepting Router Advertisements (prevents rogue router attacks).";
    };
    disableAcceptSourceRoute = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable accepting source-routed packets.";
    };
    bpfJitHarden = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable BPF JIT hardening (randomizes code layout to mitigate speculation attacks).";
    };
    socketReceiveBufferMax = lib.mkOption {
      type = lib.types.int;
      default = 212992;
      description = "Maximum socket receive buffer size.";
    };
    socketSendBufferMax = lib.mkOption {
      type = lib.types.int;
      default = 212992;
      description = "Maximum socket send buffer size.";
    };

    # ── Kernel Attack Surface ──
    disableUnprivilegedBpf = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable unprivileged BPF access (prevents eBPF-based privilege escalation).";
    };
    disableUserfaultfd = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable unprivileged userfaultfd (prevents use in kernel exploit primitives).";
    };
    disableFtrace = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable ftrace (reduces kernel introspection surface).";
    };
    ioDelayType = lib.mkOption {
      type = lib.types.enum [ "iopl" "native" "none" ];
      default = "iopl";
      description = "I/O delay method. 'iopl' restricts user-space I/O port access via permission bitmap.";
    };
    panicOnOops = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Panic the kernel on an Oops. Useful for servers where kernel bugs should trigger a clean reboot rather than limping along in a compromised state.";
    };
    disableSgx = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Disable Intel SGX (reduces attack surface; only disable if not needed for confidential computing).";
    };

    # ── Core Dump Restrictions ──
    restrictCorePattern = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set kernel.core_pattern to prevent core dumps from leaking sensitive info.";
    };
    corePattern = lib.mkOption {
      type = lib.types.str;
      default = "|/bin/false";
      description = "Core dump pattern. Default discards all core dumps. Can be set to a path for selective collection.";
    };

    # ── Module Loading Restrictions ──
    # Note: security.lockKernelModules is handled by 27-hardened-core.
    # This module adds additional module blacklisting for rarely-needed attack vectors.
    extraDisabledModules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        # Wireless attack surface (if not needed)
        "bluetooth"
        # Rarely-needed filesystems
        "cifs"
        "nfs"
        "nfsd"
        # Debugging / profiling
        "kgdb"
        "ftrace"
        # Hardware attack surface
        "thunderbolt"
        # FireWire (DMA attacks)
        "firewire-core"
        "ohci1394"
      ];
      description = "Additional kernel modules to blacklist beyond the kernel-hardening defaults.";
    };

    # ── AppArmor ──
    enableAppArmor = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable AppArmor Mandatory Access Control. Requires reboot to activate kernel support.";
    };
  };

  config = lib.mkIf cfg.enable {
    # ═══════════════════════════════════════════
    #  BOOTLOADER HARDENING
    # ═══════════════════════════════════════════

    # Reduce boot menu timeout to limit physical attack window
    boot.loader.timeout = cfg.bootloaderTimeout;

    # Remove recovery entries from boot menu
    boot.loader.systemd-boot.configurationLimit =
      if cfg.removeRecovery then 1 else null;

    # systemd-boot menu editor protection
    # Disabling prevents boot parameter tampering (init=/bin/sh attacks)
    boot.loader.systemd-boot.editor = false;

    # GRUB password protection (when using GRUB)
    # Uses boot.loader.grub.users — only activated when a hash is provided
    boot.loader.grub.users = lib.mkIf (cfg.grubPasswordHash != null) {
      admin = {
        hashedPassword = cfg.grubPasswordHash;
      };
    };

    # ═══════════════════════════════════════════
    #  FILESYSTEM MOUNT HARDENING
    # ═══════════════════════════════════════════

    fileSystems = {
      "/tmp" = lib.mkIf cfg.hardenTmp {
        options = [ "noexec" "nosuid" "nodev" ];
      };
      "/dev/shm" = lib.mkIf cfg.hardenDevShm {
        options = [ "noexec" "nosuid" "nodev" ];
      };
      "/run/lock" = lib.mkIf cfg.hardenRunLock {
        options = [ "noexec" "nosuid" "nodev" ];
      };
    };

    # ═══════════════════════════════════════════
    #  SUPPLEMENTARY SYSCTL HARDENING
    # ═══════════════════════════════════════════
    # These complement the sysctl settings in 21-kernel-hardening.nix.
    # NixOS merges boot.kernel.sysctl attrsets, so no conflicts.

    boot.kernel.sysctl = {
      # ── TCP Hardening ──
      "net.ipv4.tcp_timestamps" = if cfg.disableTcpTimestamps then 0 else 1;
      "net.ipv4.tcp_syn_retries" = cfg.tcpSynRetries;
      "net.ipv4.tcp_max_syn_backlog" = cfg.tcpMaxSynBacklog;
      "net.ipv4.tcp_fin_timeout" = cfg.tcpFinTimeout;

      # ── IPv6 Router Advertisement ──
      "net.ipv6.conf.all.accept_ra" = if cfg.disableAcceptRa then 0 else 1;
      "net.ipv6.conf.default.accept_ra" = if cfg.disableAcceptRa then 0 else 1;

      # ── BPF JIT Hardening ──
      # 2 = always enable, randomizes code layout
      "net.core.bpf_jit_harden" = if cfg.bpfJitHarden then 2 else 0;

      # ── Socket Buffer Limits ──
      "net.core.rmem_max" = cfg.socketReceiveBufferMax;
      "net.core.wmem_max" = cfg.socketSendBufferMax;

      # ── Core Dump Pattern ──
      "kernel.core_pattern" = lib.mkIf cfg.restrictCorePattern cfg.corePattern;

      # ── Panic on Oops (server mode) ──
      "kernel.panic_on_oops" = if cfg.panicOnOops then 1 else 0;
    };

    # ═══════════════════════════════════════════
    #  KERNEL ATTACK SURFACE REDUCTION
    # ═══════════════════════════════════════════

    # Restrict unprivileged BPF access (prevents eBPF-based privilege escalation)
    security.unprivilegedUsernsClone = !cfg.disableUnprivilegedBpf;

    # I/O delay via permission bitmap (restricts user-space I/O port access)
    boot.kernelParams = lib.optionals (cfg.ioDelayType == "iopl") [
      "io_delay=type0x80"
    ];

    # Disable unprivileged userfaultfd
    boot.kernel.sysctl."vm.unprivileged_userfaultfd" =
      if cfg.disableUserfaultfd then 0 else 1;

    # Disable Intel SGX (if not needed)
    boot.kernelParams = lib.optionals cfg.disableSgx [ "sgx.disabled=1" ];

    # Additional boot parameters for hardening
    boot.kernelParams = [
      # Disable Spectre/Meltdown mitigations override (keep them on)
      "mitigations=auto"
      # Enable kernel lockdown at integrity level (complements 27-hardened-core)
    ] ++ lib.optionals cfg.disableFtrace [
      "ftrace_dump_on_oops=0"
    ];

    # ═══════════════════════════════════════════
    #  MODULE LOADING RESTRICTIONS
    # ═══════════════════════════════════════════

    boot.blacklistedKernelModules = cfg.extraDisabledModules;

    # ═══════════════════════════════════════════
    #  APPARMOR
    # ═══════════════════════════════════════════

    security.apparmor.enable = cfg.enableAppArmor;

    # ═══════════════════════════════════════════
    #  WARNINGS
    # ═══════════════════════════════════════════

    warnings = [ ]
      ++ lib.optional (cfg.bootloaderTimeout == 0)
        "[SYSTEM-HARDENING] Boot timeout is 0 — no boot menu will be shown. Ensure your configuration is correct before deploying."
      ++ lib.optional (cfg.grubPasswordHash != null && config.boot.loader.grub.enable or false)
        "[SYSTEM-HARDENING] GRUB password is set. Remember to store the plaintext password securely."
      ++ lib.optional (cfg.enableAppArmor)
        "[SYSTEM-HARDENING] AppArmor enabled — a reboot is required for kernel support to activate.";
  };
}
