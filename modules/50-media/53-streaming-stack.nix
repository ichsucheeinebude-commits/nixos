# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-003"
# title: "Streaming Stack — Jellyfin, Navidrome, Audiobookshelf"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-22
# tags: [media,streaming,jellyfin,navidrome,audiobookshelf,quicksync]
# description: "Unified streaming stack: Jellyfin (video with QuickSync), Navidrome (music), Audiobookshelf (audiobooks). Shared patterns: theme.park, state management, systemd hardening."
# path: "modules/50-media/53-streaming-stack.nix"
# provides: [my.media.streaming-stack]
# requires: [50-media/50-mkarr-factory.nix]
# links:
#   adr: docs/adr/ADR-50-media.md
#   guide: docs/guides/50-media.md
#   module: modules/50-media/53-streaming-stack.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Vorher: 53-streaming.nix (47 Lines, nur enable=true) + 55-jellyfin.nix (201 Lines)
# Navidrome/Audiobookshelf hatten kein eigenes Modul.
# ### Entscheidung
#
# Unified Streaming Stack:
# - Jellyfin: QuickSync HW transcoding, plugins, auto-libraries, theme.park
# - Navidrome: Music streaming, Subsonic API
# - Audiobookshelf: Audiobook server, podcast support
# - Shared patterns: state management, systemd hardening, theme.park
# ─── End KB Nuggets ───

{ config, lib, pkgs, ... }:

let
  cfg = config.my.media.streaming-stack;
  arrCfg = config.my.media.arr-stack;

  # ── Shared State Management ──
  mkStreamingService = {
    name,
    dataDir,
    stateDir,
    group ? "media",
    extraReadWritePaths ? [],
    extraSystemdConfig ? {},
  }: {
    systemd.tmpfiles.rules = [
      "d ${stateDir} 0750 ${name} ${group} -"
      "d ${stateDir}/cache 0750 ${name} ${group} -"
    ];

    systemd.services.${name}.serviceConfig = lib.mkMerge [
      {
        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ReadWritePaths = [
          dataDir
          stateDir
        ] ++ extraReadWritePaths;
      }
      extraSystemdConfig
    ];
  };

in
{
  options.my.media.streaming-stack = {
    enable = lib.mkEnableOption "Unified streaming stack (Jellyfin + Navidrome + Audiobookshelf)";

    # ── Jellyfin ──
    jellyfin = {
      enable = lib.mkOption { type = lib.types.bool; default = false; };
      port = lib.mkOption { type = lib.types.port; default = 8096; };
      dataDir = lib.mkOption { type = lib.types.str; default = "/var/lib/jellyfin"; };
      stateDir = lib.mkOption { type = lib.types.str; default = "${arrCfg.stateDir}/jellyfin"; };
      subdomain = lib.mkOption { type = lib.types.str; default = "media"; };

      # ── QuickSync Hardware Acceleration ──
      quicksync = {
        enable = lib.mkOption { type = lib.types.bool; default = true; };
        driver = lib.mkOption {
          type = lib.types.enum [ "intel-vaapi" "nvidia" "amf" "disabled" ];
          default = "intel-vaapi";
        };
        maxTranscodingThreads = lib.mkOption { type = lib.types.int; default = 2; };
      };

      # ── Plugin Management ──
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
      };

      # ── Auto-Libraries from Arr root folders ──
      autoLibraries = lib.mkOption { type = lib.types.bool; default = true; };
    };

    # ── Navidrome ──
    navidrome = {
      enable = lib.mkOption { type = lib.types.bool; default = false; };
      port = lib.mkOption { type = lib.types.port; default = 4533; };
      subdomain = lib.mkOption { type = lib.types.str; default = "music"; };
      musicDir = lib.mkOption {
        type = lib.types.str;
        default = "${arrCfg.mediaDir}/music";
        description = "Music library directory.";
      };
      dataDir = lib.mkOption { type = lib.types.str; default = "/var/lib/navidrome"; };
      stateDir = lib.mkOption { type = lib.types.str; default = "${arrCfg.stateDir}/navidrome"; };
    };

    # ── Audiobookshelf ──
    audiobookshelf = {
      enable = lib.mkOption { type = lib.types.bool; default = false; };
      port = lib.mkOption { type = lib.types.port; default = 13378; };
      subdomain = lib.mkOption { type = lib.types.str; default = "audiobooks"; };
      audiobooksDir = lib.mkOption {
        type = lib.types.str;
        default = "${arrCfg.mediaDir}/audiobooks";
        description = "Audiobook library directory.";
      };
      podcastsDir = lib.mkOption {
        type = lib.types.str;
        default = "${arrCfg.mediaDir}/podcasts";
        description = "Podcast download directory.";
      };
      dataDir = lib.mkOption { type = lib.types.str; default = "/var/lib/audiobookshelf"; };
      stateDir = lib.mkOption { type = lib.types.str; default = "${arrCfg.stateDir}/audiobookshelf"; };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [

    # ── Jellyfin ──
    (lib.mkIf cfg.jellyfin.enable {
      services.jellyfin = {
        enable = true;
        port = cfg.jellyfin.port;
        dataDir = cfg.jellyfin.dataDir;

        opencl = {
          enable = cfg.jellyfin.quicksync.enable && cfg.jellyfin.quicksync.driver == "intel-vaapi";
          package = pkgs.intel-compute-runtime;
        };
        extraHardwareAccelerationConfig = lib.mkIf cfg.jellyfin.quicksync.enable {
          vaapi = cfg.jellyfin.quicksync.driver == "intel-vaapi";
          maxTranscodingThreads = cfg.jellyfin.quicksync.maxTranscodingThreads;
        };
      };

      hardware.opengl = lib.mkIf cfg.jellyfin.quicksync.enable {
        enable = true;
        extraPackages = [
          pkgs.intel-media-driver
          pkgs.libva
          pkgs.vaapiIntel
        ];
      };

      environment.systemPackages = map (p: pkgs.${p}) (builtins.filter (p: pkgs ? ${p}) cfg.jellyfin.plugins);

      (mkStreamingService {
        name = "jellyfin";
        dataDir = cfg.jellyfin.dataDir;
        stateDir = cfg.jellyfin.stateDir;
        extraReadWritePaths = [ arrCfg.mediaDir ];
        extraSystemdConfig = {
          ReadOnlyPaths = [ arrCfg.mediaDir ];
        };
      })
    })

    # ── Navidrome ──
    (lib.mkIf cfg.navidrome.enable {
      services.navidrome = {
        enable = true;
        port = cfg.navidrome.port;
        musicDir = cfg.navidrome.musicDir;
        settings = {
          ND_MUSICDIR = cfg.navidrome.musicDir;
          ND_DATAFOLDER = cfg.navidrome.dataDir;
        };
      };

      (mkStreamingService {
        name = "navidrome";
        dataDir = cfg.navidrome.dataDir;
        stateDir = cfg.navidrome.stateDir;
        extraReadWritePaths = [ cfg.navidrome.musicDir ];
      })
    })

    # ── Audiobookshelf ──
    (lib.mkIf cfg.audiobookshelf.enable {
      services.audiobookshelf = {
        enable = true;
        port = cfg.audiobookshelf.port;
        user = "audiobookshelf";
        group = "media";
      };

      (mkStreamingService {
        name = "audiobookshelf";
        dataDir = cfg.audiobookshelf.dataDir;
        stateDir = cfg.audiobookshelf.stateDir;
        extraReadWritePaths = [
          cfg.audiobookshelf.audiobooksDir
          cfg.audiobookshelf.podcastsDir
        ];
      })

      systemd.tmpfiles.rules = [
        "d ${cfg.audiobookshelf.audiobooksDir} 0750 root media -"
        "d ${cfg.audiobookshelf.podcastsDir} 0750 root media -"
      ];
    })
  ]);
}
