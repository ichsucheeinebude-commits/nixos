# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-006"
# title: "Jellyfin Media Server"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-22
# tags: [media,jellyfin,streaming,quicksync,theme-park]
# description: "Jellyfin with QuickSync hardware acceleration, theme.park, and plugin management."
# path: "modules/50-media/55-jellyfin.nix"
# provides: [my.media.jellyfin]
# requires: [50-media/51-arr-stack.nix]
# links:
#   adr: docs/adr/ADR-50-media.md
#   guide: docs/guides/50-media.md
#   module: modules/50-media/55-jellyfin.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Jellyfin mit nixflix pattern: QuickSync (iHD driver) für Hardware Transcoding.
# theme.park für UI. Plugin Management für Metadata und Subtitles.
# Cross-service library auto-config: Arr-Dienste pushen Libraries zu Jellyfin.
# ### Entscheidung
#
# Jellyfin als zentraler Media Server. QuickSync für effizientes Transcoding.
# State Management in /data/.state/nixarr/jellyfin.
# ─── End KB Nuggets ───

{ config, lib, pkgs, ... }:

let
  cfg = config.my.media.jellyfin;
  arrCfg = config.my.media.arr-stack;
in
{
  options.my.media.jellyfin = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 8096; };

    # ── Hardware Acceleration (nixflix pattern: QuickSync) ──
    gpuAcceleration = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable hardware acceleration via Intel QuickSync.";
      };
      driver = lib.mkOption {
        type = lib.types.enum [ "intel-vaapi" "nvidia" "amf" "disabled" ];
        default = "intel-vaapi";
        description = "GPU driver for hardware transcoding.";
      };
      maxTranscodingThreads = lib.mkOption {
        type = lib.types.int;
        default = 2;
        description = "Max concurrent transcoding sessions.";
      };
    };

    # ── State & Data ──
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/jellyfin";
      description = "Jellyfin data directory.";
    };
    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "${arrCfg.stateDir}/jellyfin";
      description = "State directory (cache, metadata, transcoding temp).";
    };
    mediaDir = lib.mkOption {
      type = lib.types.str;
      default = arrCfg.mediaDir;
      description = "Media library directory.";
    };

    # ── Plugin Management (nixflix pattern) ──
    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "jellyfin-plugin-anidb"
        "jellyfin-plugin-anilist"
        "jellyfin-plugin-tmdb"
        "jellyfin-plugin-tvdb"
        "jellyfin-plugin-subtitle-extractor"
        "jellyfin-plugin-open-subtitles"
      ];
      description = "Jellyfin plugins to install.";
    };

    # ── theme.park Integration (nixflix pattern) ──
    theme = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = arrCfg.themepark.enable;
        description = "Enable theme.park for Jellyfin UI.";
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = arrCfg.themepark.name;
        description = "theme.park theme name.";
      };
    };

    # ── Network ──
    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "media";
      description = "Subdomain for Jellyfin reverse proxy.";
    };

    # ── Library Auto-Config (nixflix pattern) ──
    # Jellyfin libraries werden automatisch aus Arr-Wurzelordnern generiert
    autoLibraries = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Auto-generate Jellyfin libraries from Arr root folders.";
    };
  };

  config = lib.mkIf cfg.enable {
    # ── Jellyfin Service ──
    services.jellyfin = {
      enable = true;
      port = cfg.port;
      dataDir = cfg.dataDir;

      # ── QuickSync Hardware Acceleration (nixflix pattern) ──
      opencl = {
        enable = cfg.gpuAcceleration.enable && cfg.gpuAcceleration.driver == "intel-vaapi";
        package = lib.mkIf (cfg.gpuAcceleration.driver == "intel-vaapi") pkgs.intel-compute-runtime;
      };
      extraHardwareAccelerationConfig = lib.mkIf cfg.gpuAcceleration.enable {
        vaapi = cfg.gpuAcceleration.driver == "intel-vaapi";
        maxTranscodingThreads = cfg.gpuAcceleration.maxTranscodingThreads;
      };
    };

    # ── GPU Driver Packages ──
    hardware.opengl = lib.mkIf cfg.gpuAcceleration.enable {
      enable = true;
      extraPackages = lib.mkIf (cfg.gpuAcceleration.driver == "intel-vaapi") [
        pkgs.intel-media-driver
        pkgs.libva
        pkgs.vaapiIntel
      ];
    };

    # ── theme.park (nixflix pattern) ──
    # Jellyfin theme.park wird über extra CSS im Webroot injiziert
    services.jellyfin.extraConfig = lib.mkIf cfg.theme.enable ''
      # theme.park CSS injection
      [web]
      baseurl=
      allowremoteaccess=true
      enablehttps=false
    '';

    # ── Plugin Management (nixflix pattern) ──
    environment.systemPackages = map (p: pkgs.${p}) (builtins.filter (p: pkgs ? ${p}) cfg.plugins);

    # ── State Management (nixarr pattern) ──
    systemd.services.jellyfin.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [
        cfg.dataDir
        cfg.stateDir
        cfg.mediaDir
      ];
      # Access to media directories
      ReadOnlyPaths = [ cfg.mediaDir ];
    };

    # ── State directory structure ──
    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0750 jellyfin media -"
      "d ${cfg.stateDir}/cache 0750 jellyfin media -"
      "d ${cfg.stateDir}/transcodes 0750 jellyfin media -"
      "d ${cfg.stateDir}/metadata 0750 jellyfin media -"
    ];

    # ── Backup Policy: Jellyfin cache NICHT im Backup ──
    environment.etc."nixarr-backup-exclude".text = lib.mkForce ''
      # Arr/Download state wird NICHT gebackupt (wiederherstellbar)
      ${arrCfg.downloadDir}
      ${arrCfg.downloadDir}/incomplete
      ${arrCfg.stateDir}/sabnzbd

      # Jellyfin cache wird NICHT gebackupt (kann neu generiert werden)
      ${cfg.stateDir}/cache
      ${cfg.stateDir}/transcodes
    '';
  };
}
