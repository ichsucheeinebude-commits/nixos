# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-INF-002"
# title: "PostgreSQL (SRE Optimized)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [postgresql,database,backup,sandboxing,performance]
# description: "PostgreSQL with optimized settings, automated backups, and strict sandboxing."
# path: "modules/20-security/23-postgresql.nix"
# provides: [my.infrastructure.postgresql]
# requires: [00-core]
# links:
#   module: modules/20-security/23-postgresql.nix
# source: _meta/20-infrastructure/postgresql.nix (NIXH-20-INF-002)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
  cfg = config.my.infrastructure.postgresql;
in
{
  options.my.infrastructure.postgresql = {
    enable = lib.mkEnableOption "PostgreSQL database cluster";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.postgresql_17;
      description = "PostgreSQL package to use.";
    };
    databases = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "miniflux" "paperless" "n8n" ];
      description = "Databases to ensure.";
    };
    sharedBuffers = lib.mkOption {
      type = lib.types.str;
      default = "512MB";
      description = "Shared buffers size.";
    };
    effectiveCacheSize = lib.mkOption {
      type = lib.types.str;
      default = "4GB";
      description = "Effective cache size.";
    };
    workMem = lib.mkOption {
      type = lib.types.str;
      default = "8MB";
      description = "Work memory per operation.";
    };
    logSlowQueries = lib.mkOption {
      type = lib.types.int;
      default = 250;
      description = "Log queries slower than N ms.";
    };
    backupLocation = lib.mkOption {
      type = lib.types.str;
      default = "/data/state/backups/postgresql";
      description = "Backup directory.";
    };
    backupTime = lib.mkOption {
      type = lib.types.str;
      default = "01:30";
      description = "Backup schedule (systemd calendar format).";
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = cfg.package;
      initdbArgs = [ "--data-checksums" ];
      ensureDatabases = cfg.databases;
      ensureUsers = map (db: { name = db; ensureDBOwnership = true; }) cfg.databases;
      enableJIT = true;
      settings = {
        shared_buffers = cfg.sharedBuffers;
        effective_cache_size = cfg.effectiveCacheSize;
        maintenance_work_mem = "128MB";
        checkpoint_completion_target = 0.9;
        wal_buffers = "16MB";
        default_statistics_target = 100;
        random_page_cost = 1.1;
        effective_io_concurrency = 200;
        work_mem = cfg.workMem;
        min_wal_size = "512MB";
        max_wal_size = "2GB";
        huge_pages = "try";
        log_min_duration_statement = cfg.logSlowQueries;
        log_checkpoints = "on";
        log_connections = "on";
        log_disconnections = "on";
        log_lock_waits = "on";
      };
    };

    services.postgresqlBackup = {
      enable = true;
      databases = cfg.databases;
      location = cfg.backupLocation;
      startAt = cfg.backupTime;
    };

    systemd.services.postgresql.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      NoNewPrivileges = true;
      SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
      OOMScoreAdjust = -900;
    };
  };
}
