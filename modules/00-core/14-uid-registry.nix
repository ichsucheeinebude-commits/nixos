# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-014"
# title: "Static UID Registry"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [core,uid-registry,nftables,skuid,identity]
# description: "Combined static UID registry for nftables skuid filtering. Single Source of Truth mapping service names to UIDs in range 2000-2999."
# path: "modules/00-core/14-uid-registry.nix"
# provides: [my.users.registry]
# requires: []
# links:
#   module: modules/00-core/14-uid-registry.nix
# source: mynixos-v5/modules/core/uid-registry.nix, users-registry.nix
# ---
# ---ENDNIXMETA

{ lib, config, ... }:

let
  cfg = config.my.users.registry;
  uidValues = lib.attrValues cfg;
  uniqueUids = lib.unique uidValues;
in
{
  # ── Combined Static UID Registry ──
  # Merged from uid-registry.nix + users-registry.nix (v5)
  # Range: 2000-2999 for persistent services with network identity.
  # Used for zero-trust nftables 'meta skuid' filtering.

  options.my.users.registry = lib.mkOption {
    type = lib.types.attrsOf lib.types.int;
    default = {
      # ── Core Infrastructure (2000-2049) ──
      caddy = 2000;
      pocket-id = 2001;
      postgresql = 2002;
      valkey = 2003;
      blocky = 2004;
      vector = 2005;
      step-ca = 2006;

      # ── Monitoring (2010-2019) ──
      gatus = 2010;
      uptime-kuma = 2011;
      netdata = 2012;
      ntfy = 2013;
      scrutiny = 2014;

      # ── DNS & Network (2020-2029) ──
      adguardhome = 2020;
      ddns-updater = 2021;

      # ── Media Stack (2030-2049) ──
      jellyfin = 2030;
      audiobookshelf = 2031;
      navidrome = 2032;
      sonarr = 2040;
      radarr = 2041;
      prowlarr = 2042;
      sabnzbd = 2043;
      lidarr = 2044;
      readarr = 2045;
      jellyseerr = 2046;

      # ── Productivity & Apps (2050-2099) ──
      paperless = 2050;
      vaultwarden = 2051;
      miniflux = 2052;
      n8n = 2053;
      filebrowser = 2054;
      linkding = 2055;
      home-assistant = 2056;
      zigbee2mqtt = 2057;
      mosquitto = 2058;
      matrix = 2059;
      forgejo = 2060;
      amp = 2061;
    };
    description = "Static UID registry for all services. Range 2000-2999.";
  };

  # ── Duplicate UID Detection ──
  config.assertions = [
    {
      assertion = lib.length uidValues == lib.length uniqueUids;
      message = "🚫 [UID-CONFLICT] Duplicate UIDs detected in uid-registry!";
    }
  ];
}
