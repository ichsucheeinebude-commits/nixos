# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-060"
# title: "ARR Stack Factory"
# type: library
# status: draft
# complexity: 4
# reviewed: 2026-05-22
# tags: [media,factory,arr,servarr,sandboxing,library]
# description: "Central factory for generating hardened Servarr application modules. Provides mkArr function with shared hardening defaults, ABC-tiering paths, and settings/env-var helpers."
# path: "modules/50-media/60-arr-factory.nix"
# provides: [my.media.mkArr]
# requires: [00-core]
# links:
#   module: modules/50-media/60-arr-factory.nix
# source: mynixos-v5/modules/apps/_arr-factory.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

let
  # ── Servarr Hardening Defaults (Shared across all *arr apps) ──
  servarrHardening = {
    Type = "simple";
    Restart = "on-failure";
    MemoryMax = "2G";
    CPUWeight = 30;
    OOMScoreAdjust = 600;
    RestrictNamespaces = lib.mkForce false;
  };

  # ── Servarr Settings Options Helper ──
  mkServarrSettingsOptions = name: port: lib.mkOption {
    type = lib.types.submodule {
      freeformType = (pkgs.formats.ini { }).type;
      options = {
        update = {
          mechanism = lib.mkOption {
            type = with lib.types; nullOr (enum [ "external" "builtIn" "script" ]);
            default = "external";
          };
          automatically = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
        };
        server = {
          port = lib.mkOption {
            type = lib.types.port;
            default = port;
          };
          bindAddress = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
          };
        };
        log = {
          analyticsEnabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
        };
      };
    };
    default = { };
  };

  # ── Servarr Settings → Env Vars Helper ──
  mkServarrSettingsEnvVars = name: settings: lib.pipe settings [
    (lib.mapAttrsRecursive (path: value:
      lib.optionalAttrs (value != null) {
        name = lib.toUpper "${name}__${lib.concatStringsSep "__" path}";
        value = toString (if lib.isBool value then lib.boolToString value else value);
      }
    ))
    (lib.collect (x: lib.isString x.name or false && lib.isString x.value or false))
    lib.listToAttrs
  ];

  # ── Factory: mkArr ──
  mkArr = {
    name,
    description,
    port,
    extraReadWritePaths ? [],
    envPrefix ? (lib.toUpper name),
    stateDirName ? (lib.toUpper (builtins.substring 0 1 name) + (builtins.substring 1 (builtins.stringLength name) name)),
  }:
  let
    cfg = config.my.media.${name};
    stateDir = config.my.core.paths.stateDir or "/data/state";
    tierB = config.my.core.paths.tierB or "/mnt/fast-pool";
    mediaLibrary = config.my.core.paths.mediaLibrary or "/mnt/media";
    downloads = config.my.core.paths.downloads or "/mnt/cache/downloads";
  in
  {
    options.my.meta.${name} = lib.mkOption {
      type = lib.types.attrs;
      default = {
        inherit name description port;
        title = "${description} (hardened)";
        layer = 50;
        nixpkgs.category = "services/media";
        capabilities = [ "media" "security/sandboxing" "storage/tiering" ];
        audit.last_reviewed = "2026-05-22";
        audit.complexity = 3;
      };
      readOnly = true;
    };

    options.my.media.${name} = {
      enable = lib.mkEnableOption description;
      user = lib.mkOption {
        type = lib.types.str;
        default = name;
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = "media";
      };
      stateDir = lib.mkOption {
        type = lib.types.str;
        default = "${stateDir}/${name}/.config/${stateDirName}";
        description = "Database and config (persistent tier).";
      };
      metadataDir = lib.mkOption {
        type = lib.types.str;
        default = "${tierB}/metadata/${name}";
        description = "Fast metadata cache (Tier B).";
      };
      settings = mkServarrSettingsOptions name port;
      apiKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to ${name} API Key (via Sops).";
      };
    };

    config = lib.mkIf cfg.enable {
      systemd.services.${name} = {
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        environment = mkServarrSettingsEnvVars envPrefix cfg.settings;

        serviceConfig = lib.recursiveUpdate servarrHardening {
          User = cfg.user;
          Group = cfg.group;
          LoadCredential = lib.optional (cfg.apiKeyFile != null) "${envPrefix}_API_KEY:${toString cfg.apiKeyFile}";
          BindPaths = [
            "${cfg.metadataDir}:/var/lib/${name}/MediaCover"
          ];
          ProtectSystem = "strict";
          ProtectHome = true;
          PrivateTmp = true;
          NoNewPrivileges = true;
        };
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.stateDir} 0700 ${cfg.user} ${cfg.group} -"
        "d ${cfg.metadataDir} 0775 ${cfg.user} ${cfg.group} -"
      ];
    };
  };
in
{
  inherit mkArr;
}
