# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-ARR-001"
# title: "Arr Stack Common"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [arr, factory]
# description: "Arr Stack Common module."
# path: "modules/50-media/51-arr-stack.nix"
# provides: [my.media.arr]
# requires: [50-media/50-lib-media]
# links:
#   adr: docs/adr/ADR-50-arr-stack.md
#   guide: docs/guides/50-arr-stack.md
#   module: modules/50-media/51-arr-stack.nix
# ---
# ---ENDNIXMETA

# modules/40-media/42-arr-stack.nix
#
# Domain 40 – *Arr Stack
{ config, lib, pkgs, myLib, mediaLib, ... }:

let
  cfg     = config.my.media.arr;
  secrets = config.sops.secrets;
  inherit (mediaLib) mkArr;

  arrApps = {
    prowlarr = { port = 9696; mediaSubdir = ""; };
    radarr   = { port = 7878; mediaSubdir = "movies"; };
    sonarr   = { port = 8989; mediaSubdir = "series"; };
    lidarr   = { port = 8686; mediaSubdir = "music"; };
    readarr  = { port = 8787; mediaSubdir = "books"; };
  };

  enabledAppNames = lib.attrNames arrApps;

in {
  imports = [ ./41-lib-media.nix ];

  options.my.media.arr = {
    enable = lib.mkEnableOption "Media *Arr Stack (Radarr, Sonarr, Prowlarr, Lidarr, Readarr)";
    prowlarrUrl = lib.mkOption {
      type    = lib.types.str;
      default = "http://127.0.0.1:9696";
      description = "Internal Prowlarr URL used by other *arr apps for indexer sync.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.radarr.enable   = true;
    services.sonarr.enable   = true;
    services.prowlarr.enable = true;
    services.lidarr.enable   = true;
    services.readarr.enable  = true;

    systemd.services = lib.genAttrs enabledAppNames (name: {
      serviceConfig = {
        NoNewPrivileges = true;
        PrivateTmp      = true;
        ProtectSystem   = "strict";
        ReadWritePaths  = lib.mkAfter [
          "/var/lib/${name}"
          "/var/cache/${name}"
        ] ++ lib.optional (arrApps.${name}.mediaSubdir != "") "/mnt/media/${arrApps.${name}.mediaSubdir}";
      };
    });

    my.impermanence.directories = lib.flatten (map (name: [ "/var/lib/${name}" "/var/cache/${name}" ]) enabledAppNames);

    sops.secrets = lib.genAttrs
      (map (n: "${n}_api_key") enabledAppNames ++ [ "scenenZbs_api_key" ])
      (secretName: {
        owner = if lib.hasPrefix "scenenZbs" secretName then "prowlarr" else (lib.head (lib.splitString "_" secretName));
        mode  = "0400";
        sopsFile = ../../secrets/media.yaml; # Adjusted path relative to modules/40-media/
      });

    systemd.services.prowlarr-scenenZbs-setup = {
      description = "Idempotent SceneNZBs Newznab Indexer registration in Prowlarr";
      after       = [ "prowlarr.service" "network-online.target" ];
      wants       = [ "prowlarr.service" "network-online.target" ];
      wantedBy    = [ "multi-user.target" ];
      serviceConfig = {
        Type             = "oneshot";
        RemainAfterExit  = true;
        User             = "prowlarr";
        LoadCredential = [
          "prowlarr-api-key:${secrets.prowlarr_api_key.path}"
          "scenenZbs-api-key:${secrets.scenenZbs_api_key.path}"
        ];
        ExecStart = pkgs.writeShellScript "prowlarr-scenenZbs-setup" ''
          set -euo pipefail
          BASE="http://127.0.0.1:9696"
          PROWLARR_KEY=$(cat "$CREDENTIALS_DIRECTORY/prowlarr-api-key")
          SCENE_KEY=$(cat "$CREDENTIALS_DIRECTORY/scenenZbs-api-key")

          for i in $(seq 1 12); do
            if ${pkgs.curl}/bin/curl -sf -H "X-Api-Key: $PROWLARR_KEY" "$BASE/api/v1/system/status" > /dev/null 2>&1; then break; fi
            sleep 5
          done

          EXISTING=$(${pkgs.curl}/bin/curl -sf -H "X-Api-Key: $PROWLARR_KEY" "$BASE/api/v1/indexer" | ${pkgs.jq}/bin/jq -r '.[] | select(.name == "SceneNZBs") | .id')
          if [ -n "$EXISTING" ]; then exit 0; fi

          PAYLOAD=$(${pkgs.jq}/bin/jq -n --arg apiKey "$SCENE_KEY" \
            '{name:"SceneNZBs",implementation:"Newznab",configContract:"NewznabSettings",enable:true,priority:25,
              fields:[{name:"baseUrl",value:"https://scenenzbs.com"},{name:"apiKey",value:$apiKey},
              {name:"categories",value:[2000,2010,2020,2030,2040,2050,5000,5010,5020,5030,5040]},{name:"animeCategories",value:[5070]}]}')
          ${pkgs.curl}/bin/curl -sf -X POST "$BASE/api/v1/indexer" -H "X-Api-Key: $PROWLARR_KEY" -H "Content-Type: application/json" -d "$PAYLOAD"
        '';
      };
    };

    my.services.caddy.virtualHosts = lib.mkMerge (map (name: {
      "${name}.${config.my.domain}" = { upstream = "http://127.0.0.1:${toString arrApps.${name}.port}"; forwardAuth = true; };
    }) enabledAppNames);
  };
}
