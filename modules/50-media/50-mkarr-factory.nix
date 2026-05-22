# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-000"
# title: "Arr Factory — Declarative *Arr Service Generator"
# type: module
# status: draft
# complexity: 4
# reviewed: 2026-05-22
# tags: [media,arr-stack,factory,theme-park,trash-guides,state-management]
# description: "Single factory function that generates all *arr services (Sonarr, Radarr, Lidarr, Prowlarr, Readarr) with shared patterns: theme.park, TRaSH-Guides, state management, systemd hardening."
# path: "modules/50-media/50-mkarr-factory.nix"
# provides: [my.media.arr-factory]
# requires: [my.media.arr-stack]
# links:
#   adr: docs/adr/ADR-50-media.md
#   guide: docs/guides/50-media.md
#   module: modules/50-media/50-mkarr-factory.nix
# sources: [nix-media-server/nixarr, kiriwalawren/nixflix]
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Vorher: 6 Dateien, ~954 Lines, 80% Copy-Paste (stateDir, systemd hardening,
# theme.park, RestartTriggers, ReadWritePaths).
# ### Entscheidung
#
# mkArr Factory: Eine Funktion generiert alle *arr-Dienste mit:
# - Gemeinsamen Patterns (stateDir, systemd hardening, theme.park)
# - Service-spezifischen Werten (port, subdomain, rootFolders, quality profile)
# - Reduziert ~650 Lines Redundanz → ~300 Lines
# ─── End KB Nuggets ───

{ config, lib, pkgs, ... }:

let
  cfg = config.my.media.arr-factory;
  baseCfg = config.my.media.arr-stack;

  # ── Factory Function ──
  mkArrService = {
    name,
    serviceName,
    port,
    subdomain,
    group ? "media",
    rootFolders ? [],
    extraServiceDirs ? [],
    qualityProfile ? {},
    extraSystemdConfig ? {},
    extraStateDirs ? [],
  }:
    let
      stateDir = "${baseCfg.stateDir}/${serviceName}";
      themeparkDir = "/var/lib/theme-park/${serviceName}";
    in
    {
      # ── Service Enable ──
      config = lib.mkIf cfg.${serviceName}.enable {
        # ── NixOS Service ──
        "services.${serviceName}" = {
          enable = true;
          port = port;
          group = lib.mkIf (group != "prowlarr") group;
          extraServiceDirs = lib.optionals baseCfg.themepark.enable (
            [ themeparkDir ] ++ extraServiceDirs
          );
        };

        # ── Systemd Hardening ──
        "systemd.services.${serviceName}.serviceConfig" = lib.mkMerge [
          {
            ProtectSystem = "strict";
            ProtectHome = true;
            NoNewPrivileges = true;
            PrivateTmp = true;
            ReadWritePaths = [
              stateDir
              baseCfg.mediaDir
              baseCfg.downloadDir
            ] ++ rootFolders;
            RestartTriggers = lib.mkIf baseCfg.themepark.enable [
              config.services.theme-park.package
            ];
          }
          extraSystemdConfig
        ];

        # ── State Directory ──
        systemd.tmpfiles.rules = [
          "d ${stateDir} 0750 ${serviceName} ${group} -"
        ] ++ map (d: "d ${d} 0750 ${serviceName} ${group} -") extraStateDirs;
      };
    };

  # ── Service Definitions ──
  qp = baseCfg.qualityProfile;

  services = {
    radarr = mkArrService {
      name = "radarr";
      serviceName = "radarr";
      port = config.my.media.arr-stack.radarr.port;
      subdomain = config.my.media.arr-stack.radarr.subdomain;
      rootFolders = config.my.media.arr-stack.radarr.rootFolders;
      qualityProfile = {
        resolution = qp.movieResolution;
        codec = qp.movieCodec;
        minSize = qp.movieMinSize;
        maxSize = qp.movieMaxSize;
      };
    };
    sonarr = mkArrService {
      name = "sonarr";
      serviceName = "sonarr";
      port = config.my.media.arr-stack.sonarr.port;
      subdomain = config.my.media.arr-stack.sonarr.subdomain;
      rootFolders = config.my.media.arr-stack.sonarr.rootFolders;
      qualityProfile = {
        resolution = qp.seriesResolution;
        codec = qp.seriesCodec;
        maxSize = qp.seriesMaxSize;
      };
    };
    lidarr = mkArrService {
      name = "lidarr";
      serviceName = "lidarr";
      port = config.my.media.arr-stack.lidarr.port;
      subdomain = config.my.media.arr-stack.lidarr.subdomain;
      rootFolders = config.my.media.arr-stack.lidarr.rootFolders;
      qualityProfile = {
        format = qp.musicFormat;
      };
    };
    prowlarr = mkArrService {
      name = "prowlarr";
      serviceName = "prowlarr";
      port = config.my.media.arr-stack.prowlarr.port;
      subdomain = config.my.media.arr-stack.prowlarr.subdomain;
      group = "prowlarr";
    };
    readarr = mkArrService {
      name = "readarr";
      serviceName = "readarr";
      port = config.my.media.arr-stack.readarr.port;
      subdomain = config.my.media.arr-stack.readarr.subdomain;
      rootFolders = config.my.media.arr-stack.readarr.rootFolders;
    };
  };

in
{
  options.my.media.arr-factory = {
    enable = lib.mkEnableOption "Arr Factory: generate all *arr services from shared patterns";

    # ── Per-Service Toggles ──
    radarr = {
      enable = lib.mkOption { type = lib.types.bool; default = false; };
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = baseCfg.radarr.subdomain;
        description = "Radarr subdomain.";
      };
    };
    sonarr = {
      enable = lib.mkOption { type = lib.types.bool; default = false; };
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = baseCfg.sonarr.subdomain;
        description = "Sonarr subdomain.";
      };
    };
    lidarr = {
      enable = lib.mkOption { type = lib.types.bool; default = false; };
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = baseCfg.lidarr.subdomain;
        description = "Lidarr subdomain.";
      };
    };
    prowlarr = {
      enable = lib.mkOption { type = lib.types.bool; default = false; };
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = baseCfg.prowlarr.subdomain;
        description = "Prowlarr subdomain.";
      };
    };
    readarr = {
      enable = lib.mkOption { type = lib.types.bool; default = false; };
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = baseCfg.readarr.subdomain;
        description = "Readarr subdomain.";
      };
    };

    # ── Expose Factory Function ──
    lib.mkArrService = lib.mkOption {
      type = lib.types.functionTo lib.types.attrs;
      default = mkArrService;
      visible = false;
      description = "Factory function to create custom *arr services.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    services.radarr.config
    services.sonarr.config
    services.lidarr.config
    services.prowlarr.config
    services.readarr.config
  ]);
}
