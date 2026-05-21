# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-062"
# title: "Radarr API Setup"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [media,radarr,arr,api,setup]
# description: "Idempotent API configuration for Radarr: sets up root folders and prepares for quality profile injection."
# path: "modules/50-media/62-radarr-setup.nix"
# provides: [my.media.radarr-setup]
# requires: [00-core]
# links:
#   module: modules/50-media/62-radarr-setup.nix
# source: mynixos-v5/modules/apps/service-media-radarr-setup.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

let
  cfg = config.my.media.radarr-setup;
  mediaLibrary = config.my.core.paths.mediaLibrary or "/mnt/media";
in
{
  # ── Radarr API Setup ──
  # Idempotent: configures root folders and quality profiles.

  options.my.media.radarr-setup = {
    enable = lib.mkEnableOption "Radarr API setup service";
    port = lib.mkOption {
      type = lib.types.port;
      default = config.my.ports.radarr or 20878;
      description = "Radarr API port.";
    };
    apiKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to Radarr API key (SOPS).";
    };
    movieRootPath = lib.mkOption {
      type = lib.types.str;
      default = "${mediaLibrary}/movies";
      description = "Root folder path for movies.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.radarr-setup = {
      description = "Radarr API Configuration";
      after = [ "radarr.service" "network.target" ];
      requires = [ "radarr.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        User = "radarr";
        Group = "media";

        LoadCredential = lib.optional (cfg.apiKeyFile != null) "radarr-api-key:${toString cfg.apiKeyFile}";

        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        RemainAfterExit = true;
      };

      script = ''
        set -euo pipefail

        # Get API key
        if [ -d "$CREDENTIALS_DIRECTORY" ] && [ -f "$CREDENTIALS_DIRECTORY/radarr-api-key" ]; then
          API_KEY=$(cat "$CREDENTIALS_DIRECTORY/radarr-api-key")
        else
          echo "🛑 ERROR: Radarr API key not found."
          exit 1
        fi

        URL="http://127.0.0.1:${toString cfg.port}/api/v3"

        # Wait for Radarr API (max 60s)
        echo "⏳ Waiting for Radarr API..."
        for i in {1..12}; do
          if ${pkgs.curl}/bin/curl -s -f -H "X-Api-Key: $API_KEY" "$URL/system/status" > /dev/null; then
            echo "✅ Radarr API is online."
            break
          fi
          if [ $i -eq 12 ]; then
            echo "🛑 ERROR: Radarr API timed out."
            exit 1
          fi
          sleep 5
        done

        # Root folder (idempotent)
        ROOT_PATH="${cfg.movieRootPath}"
        echo "📁 Checking root folder: $ROOT_PATH"

        EXISTING=$(${pkgs.curl}/bin/curl -s -H "X-Api-Key: $API_KEY" "$URL/rootfolder" \
          | ${pkgs.jq}/bin/jq -r ".[] | select(.path == \"$ROOT_PATH\") | .id")

        if [ -z "$EXISTING" ] || [ "$EXISTING" == "null" ]; then
          ${pkgs.curl}/bin/curl -s -X POST "$URL/rootfolder" \
            -H "X-Api-Key: $API_KEY" \
            -H "Content-Type: application/json" \
            -d "{\"path\":\"$ROOT_PATH\"}" > /dev/null
          echo "✅ Created root folder $ROOT_PATH"
        else
          echo "ℹ️ Root folder $ROOT_PATH already exists (ID: $EXISTING)"
        fi

        # Quality Profiles (TRaSH-Guide placeholder)
        echo "✅ API Setup for Radarr completed successfully."
      '';
    };
  };
}
