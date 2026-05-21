# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-AUTO-GEN",
#   "title": "Auto Generated",
#   "layer": 99,
#   "category": "auto/gen",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["auto-generated"],
#   "description": "Auto-migrated module to NIXMETA 2.0."
# }
# ---ENDNIXMETA

{ lib, ... }:
let
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-00-COR-004";
    title = "Static UID Registry";
    description = "Single Source of Truth for static UIDs to enable zero-trust nftables skuid filtering.";
    layer = 0;
    nixpkgs.category = "core/user";
    capabilities = ["security/uid-isolation" "firewall/skuid"];
    audit.last_reviewed = "2026-05-19";
    audit.complexity = 1;
  };
in
{
  options.my.meta.uid_registry = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  # 🚀 Single Source of Truth for Static UIDs (v6.0)
  # Used for zero-trust nftables filtering (meta skuid).
  # Range: 2000-2999 for NixHome Services.

  options.my.users.registry = lib.mkOption {
    type = lib.types.attrsOf lib.types.int;
    default = {
      # 🏗️ Core Infrastructure (2000-2099)
      caddy = 2000;
      pocket-id = 2001;
      postgresql = 2002;
      valkey = 2003;
      blocky = 2004;
      vector = 2005;

      # 📦 Application Services (2100-2199)
      jellyfin = 2100;
      navidrome = 2101;
      audiobookshelf = 2102;
      sonarr = 2103;
      radarr = 2104;
      prowlarr = 2105;
      sabnzbd = 2106;
      lidarr = 2107;
      readarr = 2108;
      amp = 2109;

      # 📄 Document & Tooling (2200-2299)
      paperless = 2200;
      vaultwarden = 2201;
      miniflux = 2202;
      n8n = 2203;
      filebrowser = 2204;
      home-assistant = 2205;
      zigbee2mqtt = 2206;
      mosquitto = 2207;
      matrix = 2208;
      forgejo = 2209;

      # 📈 Monitoring (2300-2399)
      netdata = 2300;
      scrutiny = 2301;
      uptime-kuma = 2302;
      gatus = 2303;
      homepage = 2304;
    };
    description = "Static UID registry for all services.";
  };

  config.assertions = let
    uids = lib.attrValues config.my.users.registry;
    uniqueUids = lib.unique uids;
  in [
    {
      assertion = (lib.length uids) == (lib.length uniqueUids);
      message = "🚫 [UID-CONFLICT] Duplicate UIDs detected in uid-registry.nix!";
    }
  ];
}
