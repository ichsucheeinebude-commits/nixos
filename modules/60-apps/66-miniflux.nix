# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-MNF-001"
# title: "Miniflux RSS"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [miniflux, rss]
# description: "Miniflux RSS module."
# path: "modules/60-apps/66-miniflux.nix"
# provides: [my.apps.miniflux]
# requires: [10-network/10-network]
# links:
#   adr: docs/adr/ADR-60-miniflux.md
#   guide: docs/guides/60-miniflux.md
#   module: modules/60-apps/66-miniflux.nix
# ---
# ---ENDNIXMETA
# ---
# title: Miniflux RSS
# capabilities: ["tools/rss"]
# status: "hardened"
# tier_strategy: "ABC-v5.1"
# ---
{ config, lib, ... }:
let
 
 port = config.my.ports.miniflux;
 domain = config.my.configs.identity.domain;
in
{


 config = lib.mkIf config.my.services.miniflux.enable {
 services.miniflux = {
 enable = true; config = { LISTEN_ADDR = "fd://3"; WATCHDOG = 1; RUN_MIGRATIONS = 1; ADMIN_USERNAME = "admin"; };
 createDatabaseLocally = true; adminCredentialsFile = config.sops.secrets.miniflux_admin_password.path;
 };
 systemd.sockets.miniflux = { description = "Miniflux Socket"; wantedBy = [ "sockets.target" ]; listenStreams = [ (toString port) ]; };
 systemd.services.miniflux = {
    wantedBy = lib.mkForce [ ];
    requires = [ "miniflux.socket" ];
    after = [ "miniflux.socket" "postgresql.service" ];
    serviceConfig = {
      DynamicUser = true;
      StateDirectory = "miniflux";
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      SystemCallFilter = [ "@system-service" "~@privileged" ];
      OOMScoreAdjust = 500;
    };
    restartTriggers = [
      config.services.miniflux.package
      config.services.miniflux.adminCredentialsFile
    ];
  };
 };
}
