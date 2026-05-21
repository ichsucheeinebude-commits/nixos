# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-KNW-005"
# title: "Linkwarden (SRE Hardened)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [linkwarden,bookmarks,archive,sandboxing,dynamicuser]
# description: "Collaborative bookmark manager with auto-archiving and DynamicUser sandboxing."
# path: "modules/50-knowledge/52-linkwarden.nix"
# provides: [my.knowledge.linkwarden]
# requires: [10-network, 20-security]
# links:
#   module: modules/50-knowledge/52-linkwarden.nix
# source: _meta/50-knowledge/service-app-linkwarden.nix (NIXH-50-KNW-005)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
  cfg = config.my.knowledge.linkwarden;
  port = config.my.ports.linkwarden or 3000;
  domain = config.my.configs.identity.domain or "m7c5.de";
in
{
  options.my.knowledge.linkwarden = {
    enable = lib.mkEnableOption "Linkwarden collaborative bookmarks";
    nextauthUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://links.${config.my.configs.identity.domain or "m7c5.de"}/api/v1/auth";
    };
    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to environment file with secrets.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.linkwarden = {
      enable = true;
      environment = {
        NEXTAUTH_URL = cfg.nextauthUrl;
      };
    };

    services.caddy.virtualHosts."links.${domain}" = {
      extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}";
    };

    systemd.services.linkwarden.serviceConfig = {
      DynamicUser = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      SystemCallFilter = [ "@system-service" "~@privileged" ];
      OOMScoreAdjust = 300;
      StateDirectory = "linkwarden";
    };
  };
}
