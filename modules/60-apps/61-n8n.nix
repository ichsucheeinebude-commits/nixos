# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-N8N-001"
# title: "n8n Workflows"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [n8n, automation]
# description: "n8n Workflows module."
# path: "modules/60-apps/61-n8n.nix"
# provides: [my.apps.n8n]
# requires: [10-network/10-network]
# links:
#   adr: docs/adr/ADR-60-n8n.md
#   guide: docs/guides/60-n8n.md
#   module: modules/60-apps/61-n8n.nix
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, myLib, ... }:
let
 # - NIXH-30-AUT-004: Basis n8n Modul
 # - Fragment 3108: hardening (Node.js exceptions)
 # - Fragment 3331: LoadCredential for encryption keys
 # - ADR 852: ABC-Tiering Path Strategy

 cfg = config.my.apps.n8n;
 srePaths = config.my.configs.paths;
 sreConfig = config.my.configs;

in
{
 options.my.meta.n8n = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 };

  options.my.apps.n8n = {
    enable = lib.mkEnableOption "n8n Workflow Automation";
    user = lib.mkOption { type = lib.types.str; default = "n8n"; };
    group = lib.mkOption { type = lib.types.str; default = "n8n"; };
    port = lib.mkOption { type = lib.types.port; default = config.my.ports.n8n or 5678; }; 
    stateDir = lib.mkOption { 
      type = lib.types.str; 
      default = "${srePaths.stateDir}/n8n"; 
      description = "Database and binary state (Tier A/Persist)";
    };
    cacheDir = lib.mkOption {
      type = lib.types.str; 
      default = "${srePaths.tierB}/cache/n8n";
      description = "Workflow execution cache (Tier B)";
    };

    database = {
      type = lib.mkOption { 
        type = lib.types.enum [ "sqlite" "postgres" ]; 
        default = "postgres"; 
        description = "Backend database engine";
      };
    };

    encryptionKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = config.sops.secrets.n8n_enc_key.path;
      description = "Path to n8n Encryption Key (via Sops)";
    };

    memoryMax = lib.mkOption { type = lib.types.str; default = "2G"; };
  };

 config = lib.mkIf cfg.enable (lib.mkMerge [
 (myLib.mkService {
 inherit config;
 name = "n8n";
 port = cfg.port;
 useSSO = true;
 description = "n8n Workflow Automation";
 persist = true;
 readWritePaths = [ cfg.stateDir cfg.cacheDir ];
 extraServiceConfig = {
   IPAddressAllow = "any";
 };
 })


 {
 users.users.${cfg.user} = {
 isSystemUser = true;
 group = cfg.group;
 home = cfg.stateDir;
 extraGroups = [ "media" ];
 };
 users.groups.${cfg.group} = {};

 services.n8n = {
 enable = true;
 # user/group is handled via systemd override below
 };

 systemd.services.n8n = {
 description = "n8n Workflow Engine (hardened)";
 after = [ "network.target" ] ++ (lib.optional (cfg.database.type == "postgres") "postgresql.service");
 
 environment = {
 N8N_PORT = toString cfg.port;
 N8N_HOST = "127.0.0.1";
 N8N_EDITOR_BASE_URL = "https://n8n.${sreConfig.identity.subdomain}.${sreConfig.identity.domain}";
 N8N_NODE_OPTIONS = "--max-old-space-size=2048";
 
 # Pruning Policy (hardened stability)
 EXECUTIONS_DATA_PRUNE = "true";
 EXECUTIONS_DATA_MAX_AGE = "336"; # 14 days
 
 # Custom Paths
 N8N_USER_FOLDER = cfg.stateDir;
 } // (lib.optionalAttrs (cfg.database.type == "postgres") {
 DB_TYPE = "postgresdb";
 DB_POSTGRESDB_DATABASE = "n8n";
 DB_POSTGRESDB_HOST = "/run/postgresql";
 DB_POSTGRESDB_USER = "n8n";
 });

 serviceConfig = {
 User = cfg.user;
 Group = cfg.group;
 
 # Note: n8n expects N8N_ENCRYPTION_KEY in env.
 ExecStart = lib.mkForce (pkgs.writeShellScript "n8n-start" ''
   export N8N_ENCRYPTION_KEY=$(cat ${cfg.encryptionKeyFile})
   exec ${pkgs.n8n}/bin/n8n
 '');

 MemoryMax = cfg.memoryMax;
 CPUWeight = 50;
 OOMScoreAdjust = 300;
 
 ProtectSystem = "strict";
 ProtectHome = true;
 PrivateTmp = true;
 PrivateDevices = true;
 NoNewPrivileges = true;
 
 # Node.js Exceptions (Source: Fragment 9654)
 MemoryDenyWriteExecute = false; # Needed for Node.js JIT
 
 RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
 SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
 };

 restartTriggers = [
 pkgs.n8n
 config.sops.secrets.n8n_enc_key.path
 ];
 };


 services.postgresql = lib.mkIf (cfg.database.type == "postgres") {
 ensureDatabases = [ "n8n" ];
 ensureUsers = [ {
 name = "n8n";
 ensureDBOwnership = true;
 } ];
 };

      systemd.tmpfiles.rules = [
        "d ${cfg.stateDir} 0750 ${cfg.user} ${cfg.group} -"
        "d ${cfg.cacheDir} 0750 ${cfg.user} ${cfg.group} -"
      ];
    }
  ]);
}
