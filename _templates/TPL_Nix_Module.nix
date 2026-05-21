# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-XX-CAT-000",
#   "title": "REPLACE_TITLE",
#   "layer": 0,
#   "category": "REPLACE_CATEGORY",
#   "lastReviewed": "YYYY-MM-DD",
#   "reviewedBy": "moritz",
#   "status": "draft",
#   "complexity": 1,
#   "description": "REPLACE_DESCRIPTION",
#   "tags": []
# }
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

# ── REPLACE_TITLE ─────────────────────────────────────────────────────

let
  cfg = config.my.services.REPLACE_NAME;
in {

  options.my.services.REPLACE_NAME = {
    enable = lib.mkEnableOption "REPLACE_DESCRIPTION";
  };

  config = lib.mkIf cfg.enable {

    # (anchor: REPLACE_NAME-service)
    systemd.services.REPLACE_NAME = {
      description = "REPLACE_DESCRIPTION";
      wantedBy    = [ "multi-user.target" ];
      after       = [ "network.target" "sops-nix.service" ];

      serviceConfig = {
        User       = "REPLACE_NAME";
        Group      = "REPLACE_NAME";
        ProtectSystem      = "strict";
        ProtectHome        = true;
        PrivateTmp         = true;
        PrivateDevices     = true;
        NoNewPrivileges    = true;
        MemoryDenyWriteExecute = true;
        Restart            = "on-failure";
        RestartSec         = "5s";
        StateDirectory     = "REPLACE_NAME";
      };
    };

    # (anchor: REPLACE_NAME-user)
    users.users.REPLACE_NAME = {
      isSystemUser = true;
      group        = "REPLACE_NAME";
    };
    users.groups.REPLACE_NAME = {};
  };
}
