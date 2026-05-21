# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-020-SRV-DB-001",
#   "title": "PostgreSQL Database Cluster",
#   "layer": 10,
#   "category": "services/database",
#   "lastReviewed": "2026-05-14",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["database", "postgresql", "persistence"],
#   "description": "Optimized PostgreSQL cluster with socket-first configuration and automated backups."
# }
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
 # 🚀 NMS v4.0 Metadaten
 nms = {
 id = "NIXH-20-INF-002";
 title = "PostgreSQL (SRE Optimized)";
 description = "Optimized PostgreSQL cluster with socket-first configuration and automated backups.";
 layer = 10;
 nixpkgs.category = "services/database";
 capabilities = ["database/postgresql" "system/persistence" "maintenance/auto-backup"];
 audit.last_reviewed = "2026-05-14";
 audit.complexity = 2;
 };
in
{
 options.my.meta.postgresql = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 description = "NMS metadata for postgresql module";
 };


 config = lib.mkIf config.my.services.postgresql.enable {
 users.users.postgres.uid = config.my.users.registry.postgresql;
 services.postgresql = {
 enable = true;
 package = pkgs.postgresql_17;
 initdbArgs = [ "--data-checksums" ];
 ensureDatabases = [ "miniflux" "paperless" "n8n" ];
 ensureUsers = [ { name = "miniflux"; ensureDBOwnership = true; } { name = "paperless"; ensureDBOwnership = true; } { name = "n8n"; ensureDBOwnership = true; } ];
 enableJIT = true;
 settings = {
   # 🛡️ Socket-First: Listen only on local Unix socket
   listen_addresses = ""; 
   
   shared_buffers = "512MB"; effective_cache_size = "4GB"; maintenance_work_mem = "128MB"; checkpoint_completion_target = 0.9;
   wal_buffers = "16MB"; default_statistics_target = 100; random_page_cost = 1.1; effective_io_concurrency = 200;
   work_mem = "8MB"; min_wal_size = "512MB"; max_wal_size = "2GB"; huge_pages = "try";
   log_min_duration_statement = 250; log_checkpoints = "on"; log_connections = "on"; log_disconnections = "on"; log_lock_waits = "on";
 };
 };
 
 # 💾 ABC-Tiering Persistence
 environment.persistence."/persist".directories = [ "/var/lib/postgresql" ];

 services.postgresqlBackup = { 
   enable = true; 
   databases = [ "miniflux" "paperless" "n8n" ]; 
   location = "${config.my.configs.paths.tierA}/backups/postgresql"; 
   startAt = "01:30"; 
 };
 
 systemd.services.postgresql.serviceConfig = { 
   ProtectSystem = "strict"; 
   ReadWritePaths = [ 
     "/var/lib/postgresql" 
     "/run/postgresql" 
     "${config.my.configs.paths.tierA}/backups/postgresql" 
   ];
   ProtectHome = true; 
   PrivateTmp = true; 
   PrivateDevices = true; 
   PrivateNetwork = true;
   PrivateUsers = true;
   NoNewPrivileges = true; 
   RestrictNamespaces = true;
   ProtectKernelLogs = true;
   ProtectControlGroups = true;
   ProtectHostname = true;
   SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" "~@mount" "~@swap" "~@cpu-emulation" ]; 
   OOMScoreAdjust = -1000; # 🚀 Highest Priority for DB
 };

 systemd.services.postgresql.restartTriggers = [
   config.services.postgresql.package
   (builtins.toJSON config.services.postgresql.settings)
 ];

 systemd.services.miniflux.after = [ "postgresql.service" ];
 systemd.services.n8n.after = [ "postgresql.service" ];
 systemd.services.paperless-web.after = [ "postgresql.service" ];
 };
}
