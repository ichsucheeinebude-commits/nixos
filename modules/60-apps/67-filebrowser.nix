# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-009"
# title: "Filebrowser"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [filebrowser,file-manager,web-ui]
# description: "Web-based file manager with SSO integration."
# path: "modules/60-apps/67-filebrowser.nix"
# provides: [my.apps.filebrowser]
# requires: [10-network]
# links:
#   module: modules/60-apps/67-filebrowser.nix
# source: _meta/60-apps/service-app-filebrowser.nix
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.apps.filebrowser;
  port = config.my.ports.filebrowser or 20001;
  domain = config.my.configs.identity.domain or "m7c5.de";
in
{
  options.my.apps.filebrowser = {
    enable = lib.mkEnableOption "Filebrowser web file manager";
    rootPath = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/documents";
      description = "Root directory to serve.";
    };
    databasePath = lib.mkOption {
      type = lib.types.str;
      default = "/data/state/filebrowser/filebrowser.db";
    };
  };

  config = lib.mkIf cfg.enable {
    services.filebrowser = {
      enable = true;
      settings = {
        port = port;
        address = "127.0.0.1";
        root = cfg.rootPath;
        database = cfg.databasePath;
      };
    };

    services.caddy.virtualHosts."files.${domain}" = {
      extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}";
    };

    systemd.services.filebrowser.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
      OOMScoreAdjust = 300;
    };
  };
}
