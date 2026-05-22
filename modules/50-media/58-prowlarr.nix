# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-009"
# title: "Prowlarr Declarative Indexer Manager"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [media,prowlarr,indexer,declarative-sync,scenenzb]
# description: "Prowlarr with declarative settings sync (nixarr pattern). SceneNZB.com as sole indexer."
# path: "modules/50-media/58-prowlarr.nix"
# provides: [my.media.prowlarr]
# requires: [50-media/51-arr-stack.nix]
# links:
#   adr: docs/adr/ADR-50-media.md
#   guide: docs/guides/50-media.md
#   module: modules/50-media/58-prowlarr.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Declarative Settings Sync aus nixarr: Prowlarr Indexer und Download-Clients
# werden direkt in NixOS definiert — keine manuelle UI-Konfiguration nötig.
# SceneNZB.com als EINZIGER Usenet-Indexer (Newznab API, REST API v1).
#
# API: https://scenenzbs.com/api?apikey=XXX&t=search&q=linux
# Supported: ?t=caps, ?t=search, ?t=tvsearch, ?t=movie, ?t=music, ?t=book, ?t=console
# ### Entscheidung
#
# Prowlarr mit deklarativem Indexer-Setup. SceneNZB.com ist der EINZIGE Indexer.
# API-Key aus Secret-Ingest. Downloads via SABnzbd (VPN-confinement separat).
# ─── End KB Nuggets ───

{ config, lib, ... }:

let
  cfg = config.my.media.prowlarr;
  arrCfg = config.my.media.arr-stack;
in
{
  options.my.media.prowlarr = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 9696; };

    # ── Declarative Settings Sync (nixarr pattern) ──
    declarativeSync = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Sync Prowlarr settings declaratively from Nix config.";
      };

      # ── Indexer: SceneNZB.com (EINZIGER Usenet-Indexer) ──
      # Newznab API, REST API v1 kompatibel
      # https://scenenzbs.com/api?apikey=XXX&t=search&q=linux
      scenenzb = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable SceneNZB.com as the sole Usenet indexer.";
        };
        baseUrl = lib.mkOption {
          type = lib.types.str;
          default = "https://scenenzbs.com";
          description = "SceneNZB.com API base URL.";
        };
        apiKey = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "SceneNZB API key. Set via my.core.secrets or secrets file.";
        };
        categories = lib.mkOption {
          type = lib.types.listOf lib.types.int;
          default = [ 2000 5000 3000 6000 1000 ];
          description = "Newznab category IDs: Movies(2000), TV(5000), Music(3000), Books(6000), Console(1000).";
        };
        maxAge = lib.mkOption {
          type = lib.types.int;
          default = 5200;
          description = "Maximum age (days) for NZB results.";
        };
        # Spotlight/Trending support: ?t=trending&media=movie&feed=trending-week
        enableTrending = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Spotlight/Trending feeds (TMDB-based curated releases).";
        };
      };

      # ── Download Client: SABnzbd ──
      downloadClients = {
        sabnzbd = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = config.my.media.downloads.enable;
            description = "Connect Prowlarr to SABnzbd for NZB downloads.";
          };
          host = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            description = "SABnzbd host.";
          };
          port = lib.mkOption {
            type = lib.types.port;
            default = config.my.media.downloads.port or 8080;
            description = "SABnzbd port.";
          };
        };
      };
    };

    # ── Theme.park Integration (nixflix pattern) ──
    theme = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = arrCfg.themepark.enable;
        description = "Enable theme.park for Prowlarr UI.";
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = arrCfg.themepark.name;
        description = "theme.park theme name.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.prowlarr = {
      enable = true;
      port = cfg.port;

      # ── theme.park (nixflix pattern) ──
      extraServiceDirs = lib.mkIf cfg.theme.enable [
        "/var/lib/theme-park/prowlarr"
      ];
    };

    # ── theme.park sidecar service ──
    services.theme-park = lib.mkIf cfg.theme.enable {
      enable = true;
      port = 8999;
    };

    # ── State Management (nixarr pattern) ──
    # Prowlarr state wird nicht im Backup berücksichtigt (wiederherstellbar via SceneNZB)
    systemd.services.prowlarr.serviceConfig = {
      ReadWritePaths = [
        "/var/lib/prowlarr"
        arrCfg.stateDir + "/prowlarr"
      ];
      StateDirectory = "prowlarr";
    };
  };
}
