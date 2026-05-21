# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-PID-001"
# title: "Pocket-ID OIDC"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [oidc, auth]
# description: "Pocket-ID OIDC module."
# path: "modules/10-network/17-pocket-id.nix"
# provides: [my.network.pocket_id]
# requires: [10-network/10-network]
# links:
#   adr: docs/adr/ADR-10-pocket-id.md
#   guide: docs/guides/10-pocket-id.md
#   module: modules/10-network/17-pocket-id.nix
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }: 
let
  cfg = config.my.services.pocketId;
  id = config.my.configs.identity;
in {
  options.my.services.pocketId.enable = lib.mkEnableOption "Pocket-ID";

  config = lib.mkIf cfg.enable {
    services.pocket-id = {
      enable = true;
      dataDir = "${config.my.configs.paths.stateDir}/pocket-id";
      settings = {
        issuer = lib.mkForce "https://auth.${id.subdomain}.${id.domain}";
        title = "NixHome Identity";
        public_registration = false;
      };
    };

    users.users.pocket-id = {
      isSystemUser = true;
      group = "pocket-id";
      uid = config.my.users.registry.pocket-id;
    };
    users.groups.pocket-id = {};

    systemd.services.pocket-id.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectClock = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictNamespaces = true;
      MemoryDenyWriteExecute = true;
      LockPersonality = true;
      SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" "~@mount" "~@swap" "~@cpu-emulation" ];
      Restart = "always";
      RestartSec = config.my.configs.systemd.restartSec;
      OOMScoreAdjust = -900;
    };

    systemd.services.pocket-id.restartTriggers = [
      config.services.pocket-id.package
      (builtins.toJSON config.services.pocket-id.settings)
    ];
  };
}
