# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-064"
# title: "Sonarr API Setup"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [media,sonarr,arr,api,setup]
# description: "Idempotent API configuration for Sonarr: sets up root folders for TV series."
# path: "modules/50-media/64-sonarr-setup.nix"
# provides: [my.media.sonarr-setup]
# requires: [00-core]
# links:
#   module: modules/50-media/64-sonarr-setup.nix
# source: mynixos-v5/modules/apps/service-media-sonarr-setup.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

let
  cfg = config.my.media.sonarr-setup;
  mediaLibrary = config.my.core.paths.mediaLibrary or "/mnt/media";
in
{
  # ── Sonarr API Setup ──
  # Idempotent: configures root folders for TV series.

  options.my.media.sonarr-setup = {
    enable = lib.mkEnableOption "Sonarr API setup service";
    port = lib.mkOption {
      type = lib.types.port;
      default = config.my.ports.sonarr or 20989;
      description = "Sonarr API port.";
    };
    apiKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to Sonarr API key (SOPS).";
    };
    tvRootPath = lib.mkOption {
      type = lib.types.str;
      default = "${mediaLibrary}/tv";
      description = "Root folder path for TV series.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.sonarr-setup = {
      description = "Sonarr API Configuration";
      after = [ "sonarr.service" "network.target" ];
      requires = [ "sonarr.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        User = "sonarr";
        Group = "media";

        LoadCredential = lib.optional (cfg.apiKeyFile != null) "sonarr-api-key:${toString cfg.apiKeyFile}";

        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        RemainAfterExit = true;
      };

      script = ''
        set -euo pipefail

        # Get API key
        if [ -d "$CREDENTIALS_DIRECTORY" ] && [ -f "$CREDENTIALS_DIRECTORY/sonarr-api-key" ]; then
          API_KEY=$(cat "$CREDENTIALS_DIRECTORY/sonarr-api-key")
        else
          echo "🛑 ERROR: Sonarr API key not found."
          exit 1
        fi

        URL="http://127.0.0.1:${toString cfg.port}/api/v3"

        # Wait for Sonarr API (max 60s)
        echo "⏳ Waiting for Sonarr API..."
        for i in {1..12}; do
          if ${pkgs.curl}/bin/curl -s -f -H "X-Api-Key: $API_KEY" "$URL/system/status" > /dev/null; then
            echo "✅ Sonarr API is online."
            break
          fi
          if [ $i -eq 12 ]; then
            echo "🛑 ERROR: Sonarr API timed out."
            exit 1
          fi
          sleep 5
        done

        # Root folder (idempotent)
        ROOT_PATH="${cfg.tvRootPath}"
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

        echo "✅ API Setup for Sonarr completed successfully."
      '';
    };
  };
}
