# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-061"
# title: "Prowlarr Indexer Sync"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-22
# tags: [media,prowlarr,arr,api,indexer]
# description: "Idempotent API configuration for Prowlarr: registers Radarr and Sonarr as downstream applications for indexer synchronization."
# path: "modules/50-media/61-prowlarr-setup.nix"
# provides: [my.media.prowlarr-setup]
# requires: [00-core]
# links:
#   module: modules/50-media/61-prowlarr-setup.nix
# source: mynixos-v5/modules/apps/service-media-prowlarr-setup.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

let
  prowlarrCfg = config.my.media.prowlarr-setup;
  radarrPort = config.my.ports.radarr or 20878;
  sonarrPort = config.my.ports.sonarr or 20989;
in
{
  # ── Prowlarr Indexer Sync ──
  # Idempotent API setup: registers Radarr and Sonarr in Prowlarr.

  options.my.media.prowlarr-setup = {
    enable = lib.mkEnableOption "Prowlarr indexer sync setup";
    port = lib.mkOption {
      type = lib.types.port;
      default = config.my.ports.prowlarr or 20696;
      description = "Prowlarr API port.";
    };
    prowlarrApiKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to Prowlarr API key (SOPS).";
    };
    radarrApiKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to Radarr API key (SOPS).";
    };
    sonarrApiKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to Sonarr API key (SOPS).";
    };
  };

  config = lib.mkIf prowlarrCfg.enable {
    systemd.services.prowlarr-setup = {
      description = "Prowlarr Indexer Sync";
      after = [ "prowlarr.service" "radarr.service" "sonarr.service" "network.target" ];
      requires = [ "prowlarr.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        User = "prowlarr";
        Group = "media";

        LoadCredential = lib.flatten [
          (lib.optional (prowlarrCfg.prowlarrApiKeyFile != null) "prowlarr-api-key:${toString prowlarrCfg.prowlarrApiKeyFile}")
          (lib.optional (prowlarrCfg.radarrApiKeyFile != null) "radarr-api-key:${toString prowlarrCfg.radarrApiKeyFile}")
          (lib.optional (prowlarrCfg.sonarrApiKeyFile != null) "sonarr-api-key:${toString prowlarrCfg.sonarrApiKeyFile}")
        ];

        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        RemainAfterExit = true;
      };

      script = ''
        set -euo pipefail

        get_key() {
          if [ -f "$CREDENTIALS_DIRECTORY/$1" ]; then cat "$CREDENTIALS_DIRECTORY/$1"; else echo ""; fi
        }

        PROWLARR_KEY=$(get_key "prowlarr-api-key")
        RADARR_KEY=$(get_key "radarr-api-key")
        SONARR_KEY=$(get_key "sonarr-api-key")

        if [ -z "$PROWLARR_KEY" ]; then
          echo "🛑 ERROR: Prowlarr API key missing."
          exit 1
        fi

        PROWLARR_URL="http://127.0.0.1:${toString prowlarrCfg.port}/api/v1"

        # Wait for Prowlarr API
        echo "⏳ Waiting for Prowlarr API..."
        for i in {1..12}; do
          if ${pkgs.curl}/bin/curl -s -f -H "X-Api-Key: $PROWLARR_KEY" "$PROWLARR_URL/system/status" > /dev/null; then
            echo "✅ Prowlarr API is online."
            break
          fi
          sleep 5
        done

        # Register downstream app in Prowlarr
        register_app() {
          local name=$1
          local port=$2
          local key=$3

          if [ -z "$key" ]; then
            echo "⚠️ Skipping $name: No API key provided."
            return
          fi

          echo "🔗 Checking $name integration..."
          EXISTING=$(${pkgs.curl}/bin/curl -s -H "X-Api-Key: $PROWLARR_KEY" "$PROWLARR_URL/applications" \
            | ${pkgs.jq}/bin/jq -r ".[] | select(.name == \"$name\") | .id")

          if [ -z "$EXISTING" ] || [ "$EXISTING" == "null" ]; then
            echo "➕ Registering $name in Prowlarr..."
            ${pkgs.curl}/bin/curl -s -X POST "$PROWLARR_URL/applications" \
              -H "X-Api-Key: $PROWLARR_KEY" \
              -H "Content-Type: application/json" \
              -d "{
                \"name\": \"$name\",
                \"configContract\": \"$name\",
                \"implementation\": \"$name\",
                \"fields\": [
                  {\"name\": \"baseUrl\", \"value\": \"http://127.0.0.1:$port\"},
                  {\"name\": \"apiKey\", \"value\": \"$key\"}
                ],
                \"syncLevel\": \"fullAndIndexers\"
              }" > /dev/null
            echo "✅ $name registered."
          else
            echo "ℹ️ $name already registered (ID: $EXISTING)."
          fi
        }

        register_app "Radarr" "${toString radarrPort}" "$RADARR_KEY"
        register_app "Sonarr" "${toString sonarrPort}" "$SONARR_KEY"

        echo "✅ Prowlarr Indexer Sync setup completed."
      '';
    };
  };
}
