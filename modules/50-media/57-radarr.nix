# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-008"
# title: "Radarr (Movies)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [media,radarr,movies,trash-guides,theme-park]
# description: "Radarr with TRaSH-Guides quality profiles (1080p H.265) and theme.park."
# path: "modules/50-media/57-radarr.nix"
# provides: [my.media.radarr]
# requires: [50-media/51-arr-stack.nix]
# links:
#   adr: docs/adr/ADR-50-media.md
#   guide: docs/guides/50-media.md
#   module: modules/50-media/57-radarr.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Radarr mit nixflix pattern: theme.park für UI, TRaSH-Guides für Quality Profiles.
# User preference: 1080p H.265 (gute Dateigröße).
# ### Entscheidung
#
# Radarr als Teil des declarative ARR stack. Quality profiles über arr-stack.
# State in /data/.state/nixarr/radarr (NICHT im Backup).
# ─── End KB Nuggets ───

{ config, lib, ... }:

let
  cfg = config.my.media.radarr;
  arrCfg = config.my.media.arr-stack;
  qp = arrCfg.qualityProfile;
in
{
  options.my.media.radarr = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 7878; };
    subdomain = lib.mkOption {
      type = lib.types.str;
      default = arrCfg.radarr.subdomain;
      description = "Subdomain for Radarr reverse proxy.";
    };
    rootFolders = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = arrCfg.radarr.rootFolders;
      description = "Root folders for Radarr.";
    };

    # ── TRaSH-Guides Quality Profile ──
    qualityProfile = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = qp.enable;
        description = "Enable TRaSH-Guides quality profile for Radarr.";
      };
      resolution = lib.mkOption {
        type = lib.types.enum [ "2160p" "1080p" "720p" ];
        default = qp.movieResolution;
        description = "Target resolution for movies.";
      };
      codec = lib.mkOption {
        type = lib.types.enum [ "h265" "h264" "xvid" ];
        default = qp.movieCodec;
        description = "Preferred codec. H.265 = smaller files.";
      };
      minSize = lib.mkOption {
        type = lib.types.str;
        default = qp.movieMinSize;
        description = "Minimum movie file size.";
      };
      maxSize = lib.mkOption {
        type = lib.types.str;
        default = qp.movieMaxSize;
        description = "Maximum movie file size.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.radarr = {
      enable = true;
      port = cfg.port;
      group = "media";

      # ── theme.park (nixflix pattern) ──
      extraServiceDirs = lib.mkIf arrCfg.themepark.enable [
        "/var/lib/theme-park/radarr"
      ];
    };

    # ── State Management (nixarr pattern) ──
    # Radarr state NICHT im Backup (wiederherstellbar via Prowlarr/SABnzbd)
    systemd.services.radarr.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [
        "${arrCfg.stateDir}/radarr"
        arrCfg.mediaDir
        arrCfg.downloadDir
      ] ++ cfg.rootFolders;
      RestartTriggers = lib.mkIf arrCfg.themepark.enable [
        config.services.theme-park.package
      ];
    };

    # ── State directory ──
    systemd.tmpfiles.rules = [
      "d ${arrCfg.stateDir}/radarr 0750 radarr media -"
    ];
  };
}
