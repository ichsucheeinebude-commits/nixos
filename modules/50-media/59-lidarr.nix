# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-010"
# title: "Lidarr (Music)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [media,lidarr,music,theme-park]
# description: "Lidarr with TRaSH-Guides quality profiles and theme.park."
# path: "modules/50-media/59-lidarr.nix"
# provides: [my.media.lidarr]
# requires: [50-media/51-arr-stack.nix]
# links:
#   adr: docs/adr/ADR-50-media.md
#   guide: docs/guides/50-media.md
#   module: modules/50-media/59-lidarr.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Lidarr mit nixflix pattern: theme.park für UI, TRaSH-Guides für Quality Profiles.
# Music: lossless preferred.
# ### Entscheidung
#
# Lidarr als Teil des declarative ARR stack.
# State in /data/.state/nixarr/lidarr (NICHT im Backup).
# ─── End KB Nuggets ───

{ config, lib, ... }:

let
  cfg = config.my.media.lidarr;
  arrCfg = config.my.media.arr-stack;
  qp = arrCfg.qualityProfile;
in
{
  options.my.media.lidarr = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 8686; };
    subdomain = lib.mkOption {
      type = lib.types.str;
      default = arrCfg.lidarr.subdomain;
      description = "Subdomain for Lidarr reverse proxy.";
    };
    rootFolders = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = arrCfg.lidarr.rootFolders;
      description = "Root folders for Lidarr.";
    };

    # ── TRaSH-Guides Quality Profile ──
    qualityProfile = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = qp.enable;
        description = "Enable TRaSH-Guides quality profile for Lidarr.";
      };
      format = lib.mkOption {
        type = lib.types.enum [ "lossless" "320" "192" ];
        default = qp.musicFormat;
        description = "Preferred music format.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.lidarr = {
      enable = true;
      port = cfg.port;
      group = "media";

      # ── theme.park (nixflix pattern) ──
      extraServiceDirs = lib.mkIf arrCfg.themepark.enable [
        "/var/lib/theme-park/lidarr"
      ];
    };

    # ── State Management (nixarr pattern) ──
    systemd.services.lidarr.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [
        "${arrCfg.stateDir}/lidarr"
        arrCfg.mediaDir
        arrCfg.downloadDir
      ] ++ cfg.rootFolders;
      RestartTriggers = lib.mkIf arrCfg.themepark.enable [
        config.services.theme-park.package
      ];
    };

    systemd.tmpfiles.rules = [
      "d ${arrCfg.stateDir}/lidarr 0750 lidarr media -"
    ];
  };
}
