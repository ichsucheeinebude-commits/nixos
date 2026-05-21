# ---NIXMETA
# ---
# domain: XX
# id: "NIXH-XX-XXX-001"
# title: "REPLACE_TITLE"
# type: module
# status: draft
# complexity: 1
# reviewed: YYYY-MM-DD
# tags:
#   - REPLACE_TAG
# description: "REPLACE_DESCRIPTION"
# provides:
#   - my.services.NAME.enable
# requires: []
# links:
#   adr: ADR-XX-name.md
#   guide: XX-name.md
#   module: modules/XX-name.nix
# ---
# ---ENDNIXMETA

# PURPOSE: REPLACE_DESCRIPTION
# Key decisions: docs/adr/ADR-XX-name.md

{ config, lib, pkgs, ... }:

let
  cfg = config.my.services.NAME;
in {

  options.my.services.NAME = {
    enable = lib.mkEnableOption "REPLACE_DESCRIPTION";

    # (anchor: NAME-options)
  };

  config = lib.mkIf cfg.enable {

    # (anchor: NAME-service)
    systemd.services.NAME = {
      description = "REPLACE_DESCRIPTION";
      wantedBy    = [ "multi-user.target" ];
      after       = [ "network.target" ];

      serviceConfig = {
        User                     = "NAME";
        Group                    = "NAME";
        ProtectSystem            = "strict";
        ProtectHome              = true;
        PrivateTmp               = true;
        PrivateDevices           = true;
        NoNewPrivileges          = true;
        MemoryDenyWriteExecute   = true;
        StateDirectory           = "NAME";
        Restart                  = "on-failure";
        RestartSec               = "5s";
      };
    };

    # (anchor: NAME-users)
    users.users.NAME = {
      isSystemUser = true;
      group        = "NAME";
    };
    users.groups.NAME = {};

    # (anchor: NAME-persistence)
    # environment.persistence."/persist".directories = [
    #   { directory = "/var/lib/NAME"; user = "NAME"; group = "NAME"; mode = "0750"; }
    # ];
  };
}
