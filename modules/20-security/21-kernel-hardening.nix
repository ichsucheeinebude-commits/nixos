# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-KHD-001"
# title: "Kernel Hardening"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [kernel, hardening]
# description: "Kernel Hardening module."
# path: "modules/20-security/21-kernel-hardening.nix"
# provides: [my.security.kernel]
# requires: [20-security/20-fail2ban]
# links:
#   adr: docs/adr/ADR-20-kernel-hardening.md
#   guide: docs/guides/20-kernel-hardening.md
#   module: modules/20-security/21-kernel-hardening.nix
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
  in
 {

  # Comprehensive module blacklist and sysctl hardening.
  # Static declarative approach (Decision R-03).

  config = {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    boot.blacklistedKernelModules = [
      # 1. Audio (Complete elimination for headless server)
      "snd_hda_intel" "snd_hda_codec_realtek" "snd_hda_codec_analog" "snd_hda_codec_idt"
      "snd_hda_codec_via" "snd_hda_codec_conexant" "snd_hda_codec_ca0132" "snd_ac97_codec"
      "ac97_bus" "snd_via82xx" "snd_ali5451" "snd_atiixp" "snd_atiixp_modem" "snd_emu10k1"
      "snd_emu10k1x" "snd_ca0106" "snd_ymfpci" "snd_cmipci" "snd_trident" "snd_cs4232"
      "snd_cs4236" "pcspkr"

      # 2. Wireless (Q958 has no wireless hardware)
      "iwlwifi" "iwlegacy" "ath9k" "ath9k_htc" "ath5k" "ath10k_core" "ath10k_pci"
      "ath11k" "rtl8180" "rtl8187" "rtl8192ce" "rtl8192cu" "rtl8192de" "rtl8188ee"
      "rtl8192se" "rtl8723bs" "rtl8821ae" "rtl8822be" "brcmfmac" "brcmsmac" "brcmutil"
      "mt76" "mt7601u" "mt76x2u" "b43" "b43legacy" "ssb" "mwifiex" "mwifiex_pcie"
      "libertas" "p54pci" "p54usb" "zd1211rw" "wl"

      # 3. Bluetooth (No hardware)
      "bluetooth" "btusb" "btrtl" "btbcm" "btintel" "bnep" "rfcomm" "hidp"

      # 4. Legacy NICs
      "ne2k_pci" "ne" "8139too" "8139cp" "3c59x" "3c515" "3c523" "e100" "tulip"
      "de4x5" "de2104x" "lance" "pcnet32" "fealnx" "sis900" "sis190" "via_rhine"
      "via_velocity" "smc91x" "smc911x" "tms380" "ibmtr" "3c359" "lanstreamer"
      "olympic" "abyss" "skfp" "defxx" "arc-rawmode" "arc-rimi" "com90io" "com90xx"
      "ax25" "netrom" "rose"

      # 5. Legacy Storage
      "floppy" "pata_acpi" "pata_ali" "pata_amd" "pata_artop" "pata_atiixp" "pata_efar"
      "pata_hpt366" "pata_hpt37x" "pata_hpt3x2n" "pata_hpt3x3" "pata_it8213" "pata_it821x"
      "pata_jmicron" "pata_marvell" "pata_mpiix" "pata_netcell" "pata_ninja32"
      "pata_ns87415" "pata_oldpiix" "pata_opti" "pata_optidma" "pata_pcmcia"
      "pata_pdc2027x" "pata_qdi" "pata_rz1000" "pata_sc1200" "pata_serverworks"
      "pata_sil680" "pata_sis" "pata_sl82c105" "pata_triflex" "pata_via" "sr_mod" "cdrom"
      "st" "osst" "aic7xxx" "aic94xx" "sym53c8xx" "megaraid" "ppa" "imm"

      # 6. Legacy Bus & Misc
      "firewire_core" "firewire_ohci" "firewire_sbp2" "firewire_net" "parport"
      "parport_pc" "lp" "ppdev" "pcmcia" "pcmcia_core" "yenta_socket" "rsrc_nonstatic"
      "thunderbolt"

      # 7. Non-Intel GPUs
      "nouveau" "radeon" "amdgpu" "mgag200" "ast" "cirrus" "vmwgfx" "vboxvideo"
      "uvesafb" "hyperv_drm"

      # 8. Industrial/Datacenter Hardware
      "ib_core" "ib_uverbs" "ib_cm" "ib_mad" "mlx4_ib" "mlx5_ib" "rdma_cm" "iw_cm"
      "rdma_ucm" "megaraid_sas" "hpsa" "mpt3sas" "aacraid" "lpfc" "qla2xxx" "bfa" "zfcp"

      # 9. Legacy Protocols & Vulnerable Modules (Decision FW-11)
      "isdn" "hisax" "hysdn" "atm" "uvcvideo" "videodev" "ppp" "pppoe" "pppox" "slhc"
      "ip6table_filter" "esp4" "esp6" "rxrpc" "dccp" "sctp" "rds" "tipc"

      # 10. Legacy Filesystems & Vulnerable Drivers (System Hardening Update)
      "hfs" "hfsplus" "jffs2" "freevxfs" "vivid" "minix" "udf"
    ];

    boot.extraModprobeConfig = ''
      install esp4 /bin/false
      install esp6 /bin/false
      install rxrpc /bin/false
      # Strikte Whitelist-Technik: Verhindert automatisches Laden ungenutzter Module
    '';

    boot.kernel.sysctl = {
      # Network Hardening
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.core.bpf_jit_harden" = 2;
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv4.icmp_echo_ignore_broadcasts" = true;
      "net.ipv4.conf.all.secure_redirects" = false;
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv4.conf.default.accept_source_route" = 0;
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      
      "net.ipv4.conf.all.log_martians" = 1;
      "net.ipv4.conf.default.log_martians" = 1;
      "net.ipv4.tcp_rfc1337" = 1;

      # Integrity & Privacy
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
      "kernel.printk" = "3 3 3 3";
      "kernel.unprivileged_bpf_disabled" = 1; 
      "kernel.unprivileged_userns_clone" = 0; # Disables unprivileged user namespaces
      "net.core.bpf_jit_enable" = 1;
      "kernel.ftrace_enabled" = false;
      "kernel.perf_event_paranoid" = 3;
      "kernel.sysrq" = 0;
      "kernel.kexec_load_disabled" = 1; # Disables kexec (Decision KM-02)
      "kernel.yama.ptrace_scope" = 2; # Cross-process ptrace restriction (LHF-02)

      # Filesystem Hardening
      "fs.protected_hardlinks" = 1;
      "fs.protected_symlinks" = 1;
      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;
      
      # ASLR & Memory Hardening
      "vm.mmap_rnd_bits" = 32;
      "vm.unprivileged_userfaultfd" = 0; # KM-03: Mitigates heap grooming

      # Swappiness tuning for RAM-heavy streamers
      "vm.swappiness" = 10;
    };

    security.apparmor.enable = true;
    security.lockKernelModules = true; # Decision KM-01

    boot.kernelParams = [
      # CPU & Device Protection (nix-mineral alignment)
      "mitigations=auto,nosmt" # Full mitigations + Disable SMT
      "intel_iommu=on"         # Enable IOMMU
      "iommu=force"            # Force IOMMU isolation
      "pti=on"                 # Page Table Isolation

      # Memory Protection
      "slab_nomerge"          # Mitigates heap exploits
      "init_on_free=1"        # Zero memory on free
      "init_on_alloc=1"       # Zero memory on allocation
      "page_alloc.shuffle=1"  # Randomize page allocator
      "randomize_kstack_offset=on" # Randomize kernel stack offset
      "vsyscall=none"         # Disable legacy vsyscall area
      "debugfs=off"           # Disable debugfs
      # KRIT-03: Lockdown integrity is safer than sig_enforce with some modules
      "lockdown=integrity" 
      "quiet" "splash" "loglevel=3"
    ];

    # Whitelist of required generic modules (Hardware specific modules moved to hardware-profile)
    boot.kernelModules = [ "usbcore" "ext4" "wireguard" "veth" ];

    systemd.services.kernel-module-audit = {
      description = "Audit loaded kernel modules with alerting";
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "audit-modules" ''
          # List of allowed modules (merged from initrd, hardware and generic)
          ALLOWED="nvme ahci xhci_pci usbhid usb_storage sd_mod nct6775 coretemp i915 e1000e ipmi_si tpm_tis usbcore ext4 wireguard veth bridge tun tap"
          CURRENT=$(lsmod | awk 'NR>1 {print $1}')
          
          for mod in $CURRENT; do
            if ! echo "$ALLOWED" | grep -qiw "$mod"; then
              echo "AUDIT_WARNING: Unexpected kernel module detected: $mod"
            fi
          done
        '';
      };
      startAt = "daily";
    };
  };
}
