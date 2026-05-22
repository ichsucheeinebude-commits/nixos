# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-001"
# title: "ARR Stack Library"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-22
# tags: [media,arr-stack,radarr,sonarr,lidarr,prowlarr,readarr,theme-park,trash-guides]
# description: "Declarative ARR stack with theme.park, TRaSH-Guides quality profiles, and nixarr state management."
# path: "modules/50-media/51-arr-stack.nix"
# provides: [my.media.arr-stack]
# requires: [10-network, 30-storage]
# links:
#   adr: docs/adr/ADR-50-media.md
#   guide: docs/guides/50-media.md
#   module: modules/50-media/51-arr-stack.nix
# sources: [grapefruit89/mynixos, kiriwalawren/nixflix, nix-media-server/nixarr]
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Wir injizieren die Kern-Patterns aus nixflix (theme.park, deklarative Struktur)
# und nixarr (State Management /data/.state/nixarr/, VPN nur für SABnzbd).
# ### Entscheidung
#
# 1. theme.park für einheitliches Theming aller Arr-Dienste
# 2. TRaSH-Guides Quality Profiles → 1080p H.265 (gute Dateigröße)
# 3. State Management in /data/.state/nixarr/ für strukturierte Backup-Policy
# 4. Arr/SABnzbd Daten NICHT im Backup (wiederherstellbar)
# ─── End KB Nuggets ───

{ config, lib, pkgs, ... }:
let
  cfg = config.my.media.arr-stack;
in
{
  options.my.media.arr-stack = {
    enable = lib.mkEnableOption "Declarative ARR media stack (nixflix + nixarr patterns)";

    # ── Shared Settings ──
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib";
      description = "Base data directory for all ARR services.";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/data/.state/nixarr";
      description = "State directory for declarative service state (nixarr pattern). Arr state is NOT backed up (re-downloadable).";
    };

    mediaDir = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/storage/media";
      description = "Shared media library directory.";
    };

    downloadDir = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/storage/downloads";
      description = "Download directory for completed downloads (NOT in backup).";
    };

    # ── Theme.park Integration (nixflix pattern) ──
    themepark = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable unified theming via theme.park for all Arr services.";
      };
      theme = lib.mkOption {
        type = lib.types.str;
        default = "dracula";
        description = "theme.park theme name. See https://docs.theme-park.dev/theme-options/";
      };
      addons = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "theme.park addons to enable.";
      };
    };

    # ── TRaSH-Guides Quality Profiles (nixflix pattern) ──
    # User preference: 1080p H.265, gute Dateigröße
    qualityProfile = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable TRaSH-Guides inspired quality profiles.";
      };
      # Movies: 1080p H.265
      movieResolution = lib.mkOption {
        type = lib.types.enum [ "2160p" "1080p" "720p" ];
        default = "1080p";
        description = "Target movie resolution.";
      };
      movieCodec = lib.mkOption {
        type = lib.types.enum [ "h265" "h264" "xvid" ];
        default = "h265";
        description = "Preferred video codec. H.265 = smaller files, good quality.";
      };
      movieMinSize = lib.mkOption {
        type = lib.types.str;
        default = "500MB";
        description = "Minimum movie file size.";
      };
      movieMaxSize = lib.mkOption {
        type = lib.types.str;
        default = "8GB";
        description = "Maximum movie file size (H.265 1080p ~3-6GB typical).";
      };
      # Series: 1080p H.265
      seriesResolution = lib.mkOption {
        type = lib.types.enum [ "2160p" "1080p" "720p" ];
        default = "1080p";
        description = "Target series resolution.";
      };
      seriesCodec = lib.mkOption {
        type = lib.types.enum [ "h265" "h264" ];
        default = "h265";
        description = "Preferred video codec for series.";
      };
      seriesMaxSize = lib.mkOption {
        type = lib.types.str;
        default = "4GB";
        description = "Maximum per-episode file size.";
      };
      # Music: lossless preferred
      musicFormat = lib.mkOption {
        type = lib.types.enum [ "lossless" "320" "192" ];
        default = "lossless";
        description = "Preferred music format.";
      };
    };

    # ── Reverse Proxy ──
    reverseProxy = {
      domain = lib.mkOption {
        type = lib.types.str;
        default = "media.${config.my.core.identity.domain or "local"}";
        description = "Base domain for Arr services reverse proxy.";
      };
      forceSSL = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Force SSL for all Arr services.";
      };
    };

    # ── Radarr (Movies) ──
    radarr = {
      enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Radarr movie management."; };
      port = lib.mkOption { type = lib.types.port; default = 7878; description = "Radarr web interface port."; };
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = "movies";
        description = "Subdomain for Radarr.";
      };
      rootFolders = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "/mnt/storage/media/movies" ];
        description = "Root folders for Radarr.";
      };
      apiKey = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Radarr API key for cross-service integration.";
      };
    };

    # ── Sonarr (TV Shows) ──
    sonarr = {
      enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Sonarr TV show management."; };
      port = lib.mkOption { type = lib.types.port; default = 8989; description = "Sonarr web interface port."; };
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = "series";
        description = "Subdomain for Sonarr.";
      };
      rootFolders = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "/mnt/storage/media/series" ];
        description = "Root folders for Sonarr.";
      };
      apiKey = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Sonarr API key for cross-service integration.";
      };
    };

    # ── Lidarr (Music) ──
    lidarr = {
      enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Lidarr music management."; };
      port = lib.mkOption { type = lib.types.port; default = 8686; description = "Lidarr web interface port."; };
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = "music";
        description = "Subdomain for Lidarr.";
      };
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
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = "books";
        description = "Subdomain for Readarr.";
      };
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
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = "indexers";
        description = "Subdomain for Prowlarr.";
      };
    };

    # ── Systemd Service Dependencies (nixflix pattern) ──
    serviceDependencies = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = [ "unlock-raid.service" "tailscale.service" ];
      description = "Systemd services that Arr services should wait for before starting.";
    };
  };

  config = lib.mkIf cfg.enable {
    # ── Media group ──
    users.groups.media = {};

    # ── State directory structure (nixarr pattern) ──
    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0750 root media -"
      "d ${cfg.stateDir}/radarr 0750 radarr media -"
      "d ${cfg.stateDir}/sonarr 0750 sonarr media -"
      "d ${cfg.stateDir}/lidarr 0750 lidarr media -"
      "d ${cfg.stateDir}/prowlarr 0750 prowlarr prowlarr -"
      "d ${cfg.stateDir}/readarr 0750 readarr media -"
      "d ${cfg.downloadDir} 0750 root media -"
      "d ${cfg.downloadDir}/incomplete 0750 root media -"
    ];

    # ── Theme.park Sidecar Service (nixflix pattern) ──
    services.theme-park = lib.mkIf cfg.themepark.enable {
      enable = true;
      port = 8999;
    };

    # ── Radarr ──
    services.radarr = lib.mkIf cfg.radarr.enable {
      enable = true;
      port = cfg.radarr.port;
      group = "media";
      extraServiceDirs = lib.mkIf cfg.themepark.enable [
        "/var/lib/theme-park/radarr"
      ];
    };
    systemd.services.radarr.serviceConfig = lib.mkIf cfg.radarr.enable {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [
        "${cfg.stateDir}/radarr"
        cfg.mediaDir
        cfg.downloadDir
      ] ++ cfg.radarr.rootFolders;
      RestartTriggers = lib.mkIf cfg.themepark.enable [ config.services.theme-park.package ];
    };

    # ── Sonarr ──
    services.sonarr = lib.mkIf cfg.sonarr.enable {
      enable = true;
      port = cfg.sonarr.port;
      group = "media";
      extraServiceDirs = lib.mkIf cfg.themepark.enable [
        "/var/lib/theme-park/sonarr"
      ];
    };
    systemd.services.sonarr.serviceConfig = lib.mkIf cfg.sonarr.enable {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [
        "${cfg.stateDir}/sonarr"
        cfg.mediaDir
        cfg.downloadDir
      ] ++ cfg.sonarr.rootFolders;
      RestartTriggers = lib.mkIf cfg.themepark.enable [ config.services.theme-park.package ];
    };

    # ── Lidarr ──
    services.lidarr = lib.mkIf cfg.lidarr.enable {
      enable = true;
      port = cfg.lidarr.port;
      group = "media";
      extraServiceDirs = lib.mkIf cfg.themepark.enable [
        "/var/lib/theme-park/lidarr"
      ];
    };
    systemd.services.lidarr.serviceConfig = lib.mkIf cfg.lidarr.enable {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [
        "${cfg.stateDir}/lidarr"
        cfg.mediaDir
        cfg.downloadDir
      ] ++ cfg.lidarr.rootFolders;
      RestartTriggers = lib.mkIf cfg.themepark.enable [ config.services.theme-park.package ];
    };

    # ── Prowlarr ──
    services.prowlarr = lib.mkIf cfg.prowlarr.enable {
      enable = true;
      port = cfg.prowlarr.port;
      extraServiceDirs = lib.mkIf cfg.themepark.enable [
        "/var/lib/theme-park/prowlarr"
      ];
    };
    systemd.services.prowlarr.serviceConfig = lib.mkIf cfg.prowlarr.enable {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [ "${cfg.stateDir}/prowlarr" ];
      RestartTriggers = lib.mkIf cfg.themepark.enable [ config.services.theme-park.package ];
    };

    # ── Readarr ──
    services.readarr = lib.mkIf cfg.readarr.enable {
      enable = true;
      port = cfg.readarr.port;
      group = "media";
      extraServiceDirs = lib.mkIf cfg.themepark.enable [
        "/var/lib/theme-park/readarr"
      ];
    };
    systemd.services.readarr.serviceConfig = lib.mkIf cfg.readarr.enable {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [
        "${cfg.stateDir}/readarr"
        cfg.mediaDir
        cfg.downloadDir
      ] ++ cfg.readarr.rootFolders;
      RestartTriggers = lib.mkIf cfg.themepark.enable [ config.services.theme-park.package ];
    };
  };
}
