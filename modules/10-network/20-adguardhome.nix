# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-010"
# title: "AdGuard Home DNS"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [network,dns,adguard,filtering,privacy]
# description: "Declarative DNS filter with optimized cache, strict sandboxing and expert blocklists."
# path: "modules/10-network/20-adguardhome.nix"
# provides: [my.network.adguardhome]
# requires: [my.network.base, my.core.ports]
# links:
#   adr: docs/adr/ADR-10-network.md
#   guide: docs/guides/10-network.md
#   module: modules/10-network/20-adguardhome.nix
#   upstream: https://nixos.org/manual/nixos/stable/#opt-services.adguardhome.enable
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# DNS-Filterung ist die erste Verteidigungslinie gegen Tracker, Malware und
# unerwünschte Werbung. AdGuard Home bietet deklarative Konfiguration mit
# Blocklisten, DNSSEC und optimiertem Caching.
#
# ### Entscheidung
#
# **AdGuard Home Pattern:**
# 1.  **DoH Upstream** — Verschlüsselte DNS-Auflösung über HTTPS.
# 2.  **DNSSEC** — Validierung der DNS-Antworten.
# 3.  **Optimierter Cache** — 32MB, TTL 5min-24h, optimistic caching.
# 4.  **Expert-Blocklisten** — AdGuard Base, Tracking, StevenBlack, OISD Small.
# 5.  **DNS-Rewrites** — Lokale Domain-Auflösung ohne externen DNS-Server.
# 6.  **Strict Sandboxing** — CapabilityBoundingSet, ProtectSystem, NoNewPrivileges.
#
# ### SRE-Standards
#
# - Firewall bleibt geschlossen (openFirewall = false).
# - Bind an LAN + Tailscale IPs, nicht an 0.0.0.0.
# - Client-IP-Anonymisierung aktiviert.
# ─── End KB Nuggets ───

{ config, lib, ... }:

let
  lanIP = config.my.core.server.lanIP or "127.0.0.1";
  port = config.my.core.ports.adguard or 3053;
in
{
  options.my.network.adguardhome = {
    enable = lib.mkEnableOption "AdGuard Home DNS filter";
    upstreamDns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "https://1.1.1.1/dns-query" "https://8.8.8.8/dns-query" ];
      description = "DoH upstream DNS servers.";
    };
    bootstrapDns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "1.1.1.1" "8.8.8.8" ];
      description = "Bootstrap DNS for DoH resolution.";
    };
    fallbackDns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "1.1.1.1" "8.8.8.8" ];
      description = "Fallback DNS when upstream fails.";
    };
    blocklists = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          url = lib.mkOption { type = lib.types.str; };
          name = lib.mkOption { type = lib.types.str; };
        };
      });
      default = [
        { url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"; name = "AdGuard Base"; }
        { url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt"; name = "AdGuard Tracking"; }
        { url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"; name = "StevenBlack"; }
        { url = "https://small.oisd.nl/"; name = "OISD Small"; }
      ];
      description = "Blocklist feeds.";
    };
    dnsRewrites = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          domain = lib.mkOption { type = lib.types.str; };
          answer = lib.mkOption { type = lib.types.str; };
        };
      });
      default = [];
      description = "DNS rewrite rules (domain -> IP).";
    };
  };

  config = lib.mkIf config.my.network.adguardhome.enable {
    services.adguardhome = {
      enable = true;
      host = "127.0.0.1";
      port = port;
      openFirewall = false;
      settings = {
        dns = {
          bind_hosts = [ "127.0.0.1" lanIP ];
          port = 53;
          upstream_dns = config.my.network.adguardhome.upstreamDns;
          bootstrap_dns = config.my.network.adguardhome.bootstrapDns;
          fallback_dns = config.my.network.adguardhome.fallbackDns;
          cache_size = 33554432; # 32MB
          cache_ttl_min = 300;
          cache_ttl_max = 86400;
          cache_optimistic = true;
          fastest_addr = true;
          dnssec_enabled = true;
          anonymize_client_ip = true;
        };
        filtering = {
          protection_enabled = true;
          filtering_enabled = true;
        };
        filters = map (b: { inherit (b) url name; enabled = true; }) config.my.network.adguardhome.blocklists;
        rewrites = map (r: { inherit (r) domain answer; }) config.my.network.adguardhome.dnsRewrites;
      };
    };

    # ── Systemd Sandboxing ──
    systemd.services.adguardhome.serviceConfig = {
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
      ReadWritePaths = [ "/var/lib/AdGuardHome" ];
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      NoNewPrivileges = true;
      SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
      OOMScoreAdjust = -200;
    };
  };
}
