# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-012"
# title: "Seerr (Media Requests)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [media,seerr,jellyseerr,requests,sso,theme-park]
# description: "Jellyseerr media request management with theme.park and nixarr state management."
# path: "modules/50-media/63-seerr.nix"
# provides: [my.media.seerr]
# requires: [50-media/51-arr-stack.nix]
# links:
#   adr: docs/adr/ADR-50-media.md
#   guide: docs/guides/50-media.md
#   module: modules/50-media/63-seerr.nix
# sources: [mynixos-v5/modules/apps/service-media-seerr.nix]
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Seerr (Jellyseerr) mit nixflix pattern: theme.park für UI.
# State Management in /data/.state/nixarr/seerr.
# Cross-service integration: Automatische Anbindung an Jellyfin + Arr-Dienste.
# ### Entscheidung
#
# Seerr als zentrales Request-Portal. theme.park für konsistentes UI.
# State NICHT im Backup (konfigurierbar über Arr-Services).
# ─── End KB Nuggets ───

{ config, lib, ... }:

let
  cfg = config.my.media.seerr;
  arrCfg = config.my.media.arr-stack;
in
{
  options.my.media.seerr = {
    enable = lib.mkEnableOption "Jellyseerr media requests";
    port = lib.mkOption {
      type = lib.types.port;
      default = config.my.ports.jellyseerr or 25055;
      description = "Jellyseerr web UI port.";
    };

    # ── theme.park Integration (nixflix pattern) ──
    theme = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = arrCfg.themepark.enable;
        description = "Enable theme.park for Seerr UI.";
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = arrCfg.themepark.name;
        description = "theme.park theme name.";
      };
    };

    # ── Cross-Service Integration ──
    jellyfinUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://localhost:${toString config.my.media.jellyfin.port or 8096}";
      description = "Jellyfin server URL for Seerr integration.";
    };
    radarrUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://localhost:${toString arrCfg.radarr.port}";
      description = "Radarr server URL for Seerr integration.";
    };
    sonarrUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://localhost:${toString arrCfg.sonarr.port}";
      description = "Sonarr server URL for Seerr integration.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.jellyseerr = {
      enable = true;
      port = cfg.port;
    };

    # ── State Management (nixarr pattern) ──
    systemd.services.jellyseerr.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [
        "/var/lib/jellyseerr"
        "${arrCfg.stateDir}/seerr"
      ];
    };

    # ── State directory ──
    systemd.tmpfiles.rules = [
      "d ${arrCfg.stateDir}/seerr 0750 jellyseerr media -"
    ];
  };
}
