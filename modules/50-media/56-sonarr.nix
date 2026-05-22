# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-007"
# title: "Sonarr (TV Shows)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [media,sonarr,tv,trash-guides,theme-park]
# description: "Sonarr with TRaSH-Guides quality profiles (1080p H.265) and theme.park."
# path: "modules/50-media/56-sonarr.nix"
# provides: [my.media.sonarr]
# requires: [50-media/51-arr-stack.nix]
# links:
#   adr: docs/adr/ADR-50-media.md
#   guide: docs/guides/50-media.md
#   module: modules/50-media/56-sonarr.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Sonarr mit nixflix pattern: theme.park für UI, TRaSH-Guides für Quality Profiles.
# User preference: 1080p H.265 (gute Dateigröße).
# ### Entscheidung
#
# Sonarr als Teil des declarative ARR stack. Quality profiles über arr-stack.
# State in /data/.state/nixarr/sonarr (NICHT im Backup).
# ─── End KB Nuggets ───

{ config, lib, ... }:

let
  cfg = config.my.media.sonarr;
  arrCfg = config.my.media.arr-stack;
  qp = arrCfg.qualityProfile;
in
{
  options.my.media.sonarr = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 8989; };
    subdomain = lib.mkOption {
      type = lib.types.str;
      default = arrCfg.sonarr.subdomain;
      description = "Subdomain for Sonarr reverse proxy.";
    };
    rootFolders = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = arrCfg.sonarr.rootFolders;
      description = "Root folders for Sonarr.";
    };

    # ── TRaSH-Guides Quality Profile ──
    qualityProfile = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = qp.enable;
        description = "Enable TRaSH-Guides quality profile for Sonarr.";
      };
      resolution = lib.mkOption {
        type = lib.types.enum [ "2160p" "1080p" "720p" ];
        default = qp.seriesResolution;
        description = "Target resolution for series.";
      };
      codec = lib.mkOption {
        type = lib.types.enum [ "h265" "h264" ];
        default = qp.seriesCodec;
        description = "Preferred codec. H.265 = smaller files.";
      };
      maxSize = lib.mkOption {
        type = lib.types.str;
        default = qp.seriesMaxSize;
        description = "Maximum per-episode file size.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.sonarr = {
      enable = true;
      port = cfg.port;
      group = "media";

      # ── theme.park (nixflix pattern) ──
      extraServiceDirs = lib.mkIf arrCfg.themepark.enable [
        "/var/lib/theme-park/sonarr"
      ];
    };

    # ── State Management (nixarr pattern) ──
    # Sonarr state NICHT im Backup (wiederherstellbar via Prowlarr/SABnzbd)
    systemd.services.sonarr.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [
        "${arrCfg.stateDir}/sonarr"
        arrCfg.mediaDir
        arrCfg.downloadDir
      ] ++ cfg.rootFolders;
      RestartTriggers = lib.mkIf arrCfg.themepark.enable [
        config.services.theme-park.package
      ];
    };

    # ── State directory ──
    systemd.tmpfiles.rules = [
      "d ${arrCfg.stateDir}/sonarr 0750 sonarr media -"
    ];
  };
}
