# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-030-AUT-N8N-001",
#   "title": "n8n Workflow Automation (hardened)",
#   "layer": 30,
#   "category": "services/misc",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 3,
#   "tags": ["automation", "workflows", "n8n", "hardened"],
#   "description": "Hardened n8n instance with Postgres backend and Secret-Isolation."
# }
# ---ENDNIXMETA

{ config, lib, pkgs, myLib, ... }:
let
 # 🚀 NMS v4.2 Metadaten (hardened n8n)
 # Fragment-Sourcing:
 # - NIXH-30-AUT-004: Basis n8n Modul
 # - Fragment 3108: hardening (Node.js exceptions)
 # - Fragment 3331: LoadCredential for encryption keys
 # - ADR 852: ABC-Tiering Path Strategy
 nms = {
 id = "NIXH-01-APP-N8N-001";
 title = "n8n Workflow Automation (hardened)";
 description = "Hardened n8n instance with Postgres backend and Secret-Isolation.";
 layer = 30;
 nixpkgs.category = "services/misc";
 capabilities = ["automation/workflows" "security/sandboxing" "database/postgres"];
 audit.last_reviewed = "2026-04-27";
 audit.complexity = 3;
 };

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
    # 💾 PATH STRATEGY (ABC-Tiering)
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

    # 🗄️ DATABASE
    database = {
      type = lib.mkOption { 
        type = lib.types.enum [ "sqlite" "postgres" ]; 
        default = "postgres"; 
        description = "Backend database engine";
      };
    };

    # 🔑 SECRETS
    encryptionKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = config.sops.secrets.n8n_enc_key.path;
      description = "Path to n8n Encryption Key (via Sops)";
    };

    # 🏎️ RESOURCES
    memoryMax = lib.mkOption { type = lib.types.str; default = "2G"; };
  };

 config = lib.mkIf cfg.enable (lib.mkMerge [
 # 🏆 Use the hardened Service Factory
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
 # 👥 USER & GROUP (Source: Fragment 5240)
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
 
 # 🔗 N8N WORKFLOWS (anchor: n8n-workflows)
 # 🔗 N8N ENV CONFIG
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
 
 # 🔑 SECRET ISOLATION (Source: Fragment 3331)
 # Note: n8n expects N8N_ENCRYPTION_KEY in env.
 ExecStart = lib.mkForce (pkgs.writeShellScript "n8n-start" ''
   export N8N_ENCRYPTION_KEY=$(cat ${cfg.encryptionKeyFile})
   exec ${pkgs.n8n}/bin/n8n
 '');

 # 🛡️ hardening (Source: Fragment 3108)
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

 # 🗄️ POSTGRES AUTO-SETUP

 services.postgresql = lib.mkIf (cfg.database.type == "postgres") {
 ensureDatabases = [ "n8n" ];
 ensureUsers = [ {
 name = "n8n";
 ensureDBOwnership = true;
 } ];
 };

      # 📁 PERMISSION MANAGEMENT
      systemd.tmpfiles.rules = [
        "d ${cfg.stateDir} 0750 ${cfg.user} ${cfg.group} -"
        "d ${cfg.cacheDir} 0750 ${cfg.user} ${cfg.group} -"
      ];
    }
  ]);
}
/**
 * ---\n * technical_integrity:\n * checksum: sha256:e13a9c7b9600bfbd98bc1057589bcf25b5b1b8aa890de35898f63eb3211fd04f7\n * eof_marker: NIXHOME_VALID_EOF* ---\n */
