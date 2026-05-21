# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-001"
# title: "ARR Stack Library"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [media,arr-stack,radarr,sonarr,lidarr,prowlarr,readarr]
# description: "ARR Stack library module with shared options from MASTER-CONFIG-ARR-STACK."
# path: "modules/50-media/51-arr-stack.nix"
# provides: [my.media.arr-stack]
# requires: [10-network, 30-storage]
# links:
#   adr: docs/adr/ADR-51-arr-stack.md
#   guide: docs/guides/51-arr-stack.md
#   module: modules/50-media/51-arr-stack.nix
# source: guides/MASTER-CONFIG-ARR-STACK.md
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
let
  cfg = config.my.media.arr-stack;
in
{
  options.my.media.arr-stack = {
    enable = lib.mkEnableOption "ARR Stack media management suite";

    # ── Shared Settings ──
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib";
      description = "Base data directory for all ARR services.";
    };
    mediaDir = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/storage/media";
      description = "Shared media library directory.";
    };
    downloadDir = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/storage/downloads";
      description = "Download directory for completed downloads.";
    };

    # ── Radarr (Movies) ──
    radarr = {
      enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Radarr movie management."; };
      port = lib.mkOption { type = lib.types.port; default = 7878; description = "Radarr web interface port."; };
      rootFolders = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "/mnt/storage/media/movies" ];
        description = "Root folders for Radarr.";
      };
    };

    # ── Sonarr (TV Shows) ──
    sonarr = {
      enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Sonarr TV show management."; };
      port = lib.mkOption { type = lib.types.port; default = 8989; description = "Sonarr web interface port."; };
      rootFolders = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "/mnt/storage/media/series" ];
        description = "Root folders for Sonarr.";
      };
    };

    # ── Lidarr (Music) ──
    lidarr = {
      enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Lidarr music management."; };
      port = lib.mkOption { type = lib.types.port; default = 8686; description = "Lidarr web interface port."; };
      rootFolders = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "/mnt/storage/media/music" ];
        description = "Root folders for Lidarr.";
      };
    };

    # ── Readarr (Books) ──
    readarr = {
      enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Readarr book management."; };
      port = lib.mkOption { type = lib.types.port; default = 8787; description = "Readarr web interface port."; };
      rootFolders = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "/mnt/storage/media/books" ];
        description = "Root folders for Readarr.";
      };
    };

    # ── Prowlarr (Indexer Management) ──
    prowlarr = {
      enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Prowlarr indexer management."; };
      port = lib.mkOption { type = lib.types.port; default = 9696; description = "Prowlarr web interface port."; };
    };

    # ── VPN Isolation ──
    vpnIsolation = {
      enable = lib.mkOption { type = lib.types.bool; default = false; description = "Route ARR traffic through VPN."; };
      interface = lib.mkOption { type = lib.types.str; default = "wg0"; description = "VPN interface name."; };
    };
  };

  config = lib.mkIf cfg.enable {
    # Radarr
    services.radarr = lib.mkIf cfg.radarr.enable {
      enable = true;
      port = cfg.radarr.port;
      group = "media";
    };

    # Sonarr
    services.sonarr = lib.mkIf cfg.sonarr.enable {
      enable = true;
      port = cfg.sonarr.port;
      group = "media";
    };

    # Lidarr
    services.lidarr = lib.mkIf cfg.lidarr.enable {
      enable = true;
      port = cfg.lidarr.port;
      group = "media";
    };

    # Prowlarr
    services.prowlarr = lib.mkIf cfg.prowlarr.enable {
      enable = true;
      port = cfg.prowlarr.port;
    };

    # ── Media group and directories ──
    users.groups.media = {};

    # ── Systemd Hardening ──
    systemd.services.radarr.serviceConfig = lib.mkIf cfg.radarr.enable {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [ "${cfg.dataDir}/radarr" cfg.mediaDir cfg.downloadDir ] ++ cfg.radarr.rootFolders;
    };
    systemd.services.sonarr.serviceConfig = lib.mkIf cfg.sonarr.enable {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [ "${cfg.dataDir}/sonarr" cfg.mediaDir cfg.downloadDir ] ++ cfg.sonarr.rootFolders;
    };
    systemd.services.lidarr.serviceConfig = lib.mkIf cfg.lidarr.enable {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [ "${cfg.dataDir}/lidarr" cfg.mediaDir cfg.downloadDir ] ++ cfg.lidarr.rootFolders;
    };
    systemd.services.prowlarr.serviceConfig = lib.mkIf cfg.prowlarr.enable {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [ "${cfg.dataDir}/prowlarr" ];
    };
  };
}
