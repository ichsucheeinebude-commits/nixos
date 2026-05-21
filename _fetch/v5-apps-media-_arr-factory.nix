# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-040-MED-ARR-FAC",
#   "title": "Arr-Stack Service Factory",
#   "layer": 40,
#   "category": "apps/media",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 4,
#   "tags": ["media", "factory", "automation", "sandboxing"],
#   "description": "Central factory for generating hardened Servarr application modules with ABC-Tiering."
# }
# ---ENDNIXMETA

{ config, lib, pkgs, utils, myLib, ... }:

let
  # 🛡️ Servarr Hardening Defaults (Shared across all *arr apps)
  servarrHardening = {
    Type = "simple";
    Restart = "on-failure";
    MemoryMax = "2G";
    CPUWeight = 30;
    OOMScoreAdjust = 600;
    
    # .NET Specific Fixes
    RestrictNamespaces = lib.mkForce false; 
  };

  # 🛠️ Helper Functions (Inlined from old factory)
  mkServarrSettingsOptions = name: port: lib.mkOption { 
    type = lib.types.submodule { 
      freeformType = (pkgs.formats.ini { }).type; 
      options = { 
        update = { 
          mechanism = lib.mkOption { type = with lib.types; nullOr (enum [ "external" "builtIn" "script" ]); default = "external"; }; 
          automatically = lib.mkOption { type = lib.types.bool; default = false; }; 
        }; 
        server = { 
          port = lib.mkOption { type = lib.types.port; default = port; }; 
          bindAddress = lib.mkOption { type = lib.types.str; default = "127.0.0.1"; }; 
        }; 
        log = { analyticsEnabled = lib.mkOption { type = lib.types.bool; default = false; }; }; 
      }; 
    }; 
    default = { }; 
  };

  mkServarrSettingsEnvVars = name: settings: lib.pipe settings [ 
    (lib.mapAttrsRecursive (path: value: lib.optionalAttrs (value != null) { 
      name = lib.toUpper "${name}__${lib.concatStringsSep "__" path}"; 
      value = toString (if lib.isBool value then lib.boolToString value else value); 
    })) 
    (lib.collect (x: lib.isString x.name or false && lib.isString x.value or false)) 
    lib.listToAttrs 
  ];

  # 🛠️ Factory: mkArr
  mkArr = { 
    name, 
    description, 
    id, 
    port, 
    extraReadWritePaths ? [], 
    envPrefix ? (lib.toUpper name),
    stateDirName ? (lib.toUpper (substring 0 1 name) + (substring 1 (stringLength name) name)), # e.g. "sonarr" -> "Sonarr"
    nmsCategory ? "services/media",
    nmsCapabilities ? ["media" "security/sandboxing" "storage/tiering"]
  }:
  let
    cfg = config.my.media.${name};
    srePaths = config.my.configs.paths;
    
  in {
    options.my.meta.${name} = lib.mkOption {
      type = lib.types.attrs;
      default = {
        inherit id description name;
        title = "${description} (hardened)";
        layer = 40;
        nixpkgs.category = nmsCategory;
        capabilities = nmsCapabilities;
        audit.last_reviewed = "2026-05-16";
        audit.complexity = 3;
      };
      readOnly = true;
    };

    options.my.media.${name} = {
      enable = lib.mkEnableOption description;
      user = lib.mkOption { type = lib.types.str; default = name; };
      group = lib.mkOption { type = lib.types.str; default = "media"; };
      
      # 💾 PATH STRATEGY (ABC-Tiering) (anchor: arr-tiering)
      stateDir = lib.mkOption { 
        type = lib.types.str; 
        default = "${srePaths.stateDir}/${name}/.config/${stateDirName}"; 
        description = "Database and config (Tier A/Persist)";
      };
      metadataDir = lib.mkOption {
        type = lib.types.str;
        default = "${srePaths.tierB}/metadata/${name}";
        description = "Fast metadata cache (Tier B)";
      };

      # 🎖️ SETTINGS & SECRETS
      settings = mkServarrSettingsOptions name port;
      apiKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to ${name} API Key (via Sops)";
      };
    };

    config = lib.mkIf cfg.enable (lib.mkMerge [
      # 🏆 Use the hardened Service Factory
      (myLib.mkService {
        inherit config name;
        netns = "media-ns";
        port = cfg.settings.server.port;
        useSSO = true;
        description = "${description} (hardened)";
        persist = true;
        readWritePaths = [ 
          cfg.stateDir 
          cfg.metadataDir
          srePaths.mediaLibrary
          srePaths.downloads
        ] ++ extraReadWritePaths;
      })

      {
        systemd.services.${name} = {
          after = [ "network.target" "postgresql.service" ];
          wantedBy = [ "multi-user.target" ];
          
          environment = mkServarrSettingsEnvVars envPrefix cfg.settings;

          serviceConfig = lib.recursiveUpdate servarrHardening {
            User = cfg.user;
            Group = cfg.group;
            ExecStart = utils.escapeSystemdExecArgs [ (lib.getExe pkgs.${name}) "-nobrowser" "-data=${cfg.stateDir}" ];
            LoadCredential = lib.optional (cfg.apiKeyFile != null) "${envPrefix}_API_KEY:${toString cfg.apiKeyFile}";
            
            # Path Management
            BindPaths = [
              "${cfg.metadataDir}:/var/lib/${name}/MediaCover"
            ];
          };
        };

        # 📁 PERMISSION MANAGEMENT
        systemd.tmpfiles.rules = [
          "d ${cfg.stateDir} 0700 ${cfg.user} ${cfg.group} -"
          "d ${cfg.metadataDir} 0775 ${cfg.user} ${cfg.group} -"
        ];
      }
    ]);
  };
in
{
  inherit mkArr;
}
