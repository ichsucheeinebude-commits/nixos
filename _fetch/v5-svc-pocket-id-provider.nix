# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-AUTO-GEN",
#   "title": "Auto Generated",
#   "layer": 99,
#   "category": "auto/gen",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["auto-generated"],
#   "description": "Auto-migrated module to NIXMETA 2.0."
# }
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.pocket-id;
in {
  options.services.pocket-id = {
    enable = mkEnableOption "Pocket-ID OIDC Provider";
    
    package = mkOption {
      type = types.package;
      default = pkgs.pocket-id;
      description = "The pocket-id package to use.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/pocket-id";
      description = "Directory for state and database. SRE Note: Should be overridden by config.my.configs.paths.stateDir.";
    };

    user = mkOption {
      type = types.str;
      default = "pocket-id";
      description = "User under which the service runs.";
    };

    group = mkOption {
      type = types.str;
      default = "pocket-id";
      description = "Group under which the service runs.";
    };

    settings = mkOption {
      type = types.attrsOf (types.oneOf [ types.str types.bool types.int ]);
      default = {};
      description = "Environment variables for configuration.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.pocket-id = {
      description = "Pocket-ID OIDC Provider";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = mapAttrs' (name: value: 
        let
          # Prefix with POCKET_ID_ if not already present
          prefixedName = if hasPrefix "POCKET_ID_" name then name else "POCKET_ID_${name}";
        in
        nameValuePair prefixedName (if isBool value then (if value then "true" else "false") else toString value)
      ) cfg.settings;

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/pocket-id";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        StateDirectory = "pocket-id";
        # Standard Hardening
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
    };
    users.groups.${cfg.group} = {};
  };
}
