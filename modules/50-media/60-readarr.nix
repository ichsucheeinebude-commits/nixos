# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-011"
# title: "Readarr (Books)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [media,readarr,books,theme-park]
# description: "Readarr with theme.park and nixarr state management."
# path: "modules/50-media/60-readarr.nix"
# provides: [my.media.readarr]
# requires: [50-media/51-arr-stack.nix]
# links:
#   adr: docs/adr/ADR-50-media.md
#   guide: docs/guides/50-media.md
#   module: modules/50-media/60-readarr.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Readarr mit nixflix pattern: theme.park für UI.
# State Management in /data/.state/nixarr/readarr (NICHT im Backup).
# ### Entscheidung
#
# Readarr als Teil des declarative ARR stack.
# ─── End KB Nuggets ───

{ config, lib, ... }:

let
  cfg = config.my.media.readarr;
  arrCfg = config.my.media.arr-stack;
in
{
  options.my.media.readarr = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 8787; };
    subdomain = lib.mkOption {
      type = lib.types.str;
      default = arrCfg.readarr.subdomain;
      description = "Subdomain for Readarr reverse proxy.";
    };
    rootFolders = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = arrCfg.readarr.rootFolders;
      description = "Root folders for Readarr.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.readarr = {
      enable = true;
      port = cfg.port;
      group = "media";

      # ── theme.park (nixflix pattern) ──
      extraServiceDirs = lib.mkIf arrCfg.themepark.enable [
        "/var/lib/theme-park/readarr"
      ];
    };

    # ── State Management (nixarr pattern) ──
    systemd.services.readarr.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [
        "${arrCfg.stateDir}/readarr"
        arrCfg.mediaDir
        arrCfg.downloadDir
      ] ++ cfg.rootFolders;
      RestartTriggers = lib.mkIf arrCfg.themepark.enable [
        config.services.theme-park.package
      ];
    };

    systemd.tmpfiles.rules = [
      "d ${arrCfg.stateDir}/readarr 0750 readarr media -"
    ];
  };
}
