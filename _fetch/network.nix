{
  config,
  lib,
  pkgs,
  ...
}: let
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-00-COR-023";
    title = "Network (SRE Optimized)";
    description = "systemd-networkd configuration with DNS hardening, TCP BBR tuning and fast-boot optimization.";
    layer = 00;
    nixpkgs.category = "system/networking";
    capabilities = ["network/systemd-networkd" "performance/tcp-bbr" "security/dns-over-tls"];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 2;
  };
  cfg = config.my.profiles.networking.systemd-networkd;
in {
  options.my.meta.network = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  config = lib.mkIf cfg.enable {
    networking.useNetworkd = true;
    networking.useDHCP = false;
    networking.networkmanager.enable = lib.mkForce false;

    systemd.network = {
      enable = true;
      config.networkConfig.IPv6PrivacyExtensions = "kernel";
      networks."10-lan" = {
        matchConfig.Name = "en*";
        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = true;
          IPv4Forwarding = true;
          IPv6Forwarding = true;
          MulticastDNS = "yes";
          LLMNR = "no";
        };
        linkConfig.RequiredForOnline = "yes";
      };
      # 🚀 SRE Fast-Boot: Warte nur auf irgendein Interface
      wait-online.anyInterface = true;
    };

    services.resolved = {
      enable = true;
      dnssec = lib.mkForce "allow-downgrade";
      domains = ["~."];
      fallbackDns = ["1.1.1.1" "8.8.8.8"];
      extraConfig = ''
        DNSOverTLS=yes
        Cache=yes
        CacheMaxAgeSec=86400
      '';
    };

    # 🏎️ TCP STACK TUNING
    boot.kernel.sysctl = {
      "net.core.default_qdisc" = lib.mkForce "fq";
      "net.ipv4.tcp_congestion_control" = lib.mkForce "bbr";
      "net.core.netdev_max_backlog" = lib.mkForce 10000;
      "net.ipv4.tcp_slow_start_after_idle" = lib.mkForce 0;
      "net.ipv4.tcp_fastopen" = lib.mkForce 3;
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };
  };
}
/**
* ---
 * technical_integrity:
 *   checksum: sha256:3bef6134357968f31eefaea79f506af578649dd44f8bc1ffa2a35924d84112cc
 *   eof_marker: NIXHOME_VALID_EOF* ---
*/

