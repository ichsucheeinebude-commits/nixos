# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-008"
# title: "CouchDB"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [couchdb,nosql,database,document-store]
# description: "NoSQL document database with clustering support."
# path: "modules/60-apps/66-couchdb.nix"
# provides: [my.apps.couchdb]
# requires: [00-core]
# links:
#   module: modules/60-apps/66-couchdb.nix
# source: _meta/60-apps/service-app-couchdb.nix
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
  cfg = config.my.apps.couchdb;
  port = config.my.ports.couchdb or 5984;
in
{
  options.my.apps.couchdb = {
    enable = lib.mkEnableOption "CouchDB NoSQL database";
    adminUsername = lib.mkOption { type = lib.types.str; default = "admin"; };
    adminPasswordFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/secrets/couchdb_admin_password";
    };
    port = lib.mkOption { type = lib.types.port; default = port; };
  };

  config = lib.mkIf cfg.enable {
    services.couchdb = {
      enable = true;
      bindAddress = "127.0.0.1";
      port = cfg.port;
      adminUser = cfg.adminUsername;
      inherit (cfg) adminPasswordFile;
    };

    systemd.services.couchdb.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      NoNewPrivileges = true;
      OOMScoreAdjust = 500;
    };
  };
}
