#!/usr/bin/env python3
"""
MetaBibliothek Miner — Phase 2: Infrastructure, Monitoring, Apps
"""

import os

TARGET = "/root/nixos-work"

def w(path, content):
    full = os.path.join(TARGET, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, 'w') as f:
        f.write(content)
    print(f"  ✓ {path}")

# ═══════════════════════════════════════════════════════
# 11. PostgreSQL (SRE Optimized)
# ═══════════════════════════════════════════════════════
w("modules/20-security/23-postgresql.nix", '''\
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
''')

# ═══════════════════════════════════════════════════════
# 12. Valkey (Redis fork, SRE Exhausted)
# ═══════════════════════════════════════════════════════
w("modules/20-security/24-valkey.nix", '''\
# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-INF-006"
# title: "Valkey (SRE Exhausted)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [valkey,redis,cache,sandboxing,memory-cap]
# description: "Valkey (Redis fork) with memory caps, aviation-grade sandboxing."
# path: "modules/20-security/24-valkey.nix"
# provides: [my.infrastructure.valkey]
# requires: [00-core]
# links:
#   module: modules/20-security/24-valkey.nix
# source: _meta/20-infrastructure/valkey.nix (NIXH-20-INF-006)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
  cfg = config.my.infrastructure.valkey;
in
{
  options.my.infrastructure.valkey = {
    enable = lib.mkEnableOption "Valkey (Redis fork) cache";
    bind = lib.mkOption { type = lib.types.str; default = "127.0.0.1"; };
    port = lib.mkOption { type = lib.types.port; default = 6379; };
    maxmemory = lib.mkOption { type = lib.types.str; default = "512mb"; };
    maxmemoryPolicy = lib.mkOption { type = lib.types.str; default = "allkeys-lru"; };
    unixSocket = lib.mkOption { type = lib.types.str; default = "/run/redis-valkey/redis.sock"; };
  };

  config = lib.mkIf cfg.enable {
    services.redis.package = pkgs.valkey;
    services.redis.servers.valkey = {
      enable = true;
      bind = cfg.bind;
      port = cfg.port;
      openFirewall = false;
      settings = {
        maxmemory = cfg.maxmemory;
        maxmemory-policy = cfg.maxmemoryPolicy;
        save = [ "900 1" "300 10" "60 10000" ];
        unixsocket = cfg.unixSocket;
        unixsocketperm = lib.mkForce "770";
      };
    };

    systemd.services.redis-valkey.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      NoNewPrivileges = true;
      MemoryDenyWriteExecute = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_UNIX" ];
      OOMScoreAdjust = -500;
    };
  };
}
''')

# ═══════════════════════════════════════════════════════
# 13. ClamAV (SRE Exhausted)
# ═══════════════════════════════════════════════════════
w("modules/20-security/25-clamav.nix", '''\
# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-INF-001"
# title: "ClamAV (SRE Exhausted)"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [clamav,antivirus,security,scanning]
# description: "Professional antivirus with scheduled scanning and low-priority resource limits."
# path: "modules/20-security/25-clamav.nix"
# provides: [my.infrastructure.clamav]
# requires: []
# links:
#   module: modules/20-security/25-clamav.nix
# source: _meta/20-infrastructure/clamav.nix (NIXH-20-INF-001)
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.infrastructure.clamav;
in
{
  options.my.infrastructure.clamav = {
    enable = lib.mkEnableOption "ClamAV antivirus";
    scanDirectories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "/home" "/var/lib" "/etc" ];
      description = "Directories to scan.";
    };
    excludePaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "^/mnt/media" "^/mnt/fast-pool/downloads" ];
      description = "Regex patterns to exclude from scanning.";
    };
    scanInterval = lib.mkOption {
      type = lib.types.str;
      default = "Sat *-*-* 03:00:00";
      description = "Scanner schedule.";
    };
    maxScanSize = lib.mkOption {
      type = lib.types.str;
      default = "100M";
    };
    maxFileSize = lib.mkOption {
      type = lib.types.str;
      default = "50M";
    };
  };

  config = lib.mkIf cfg.enable {
    services.clamav = {
      daemon.enable = true;
      updater.enable = true;
      scanner = {
        enable = true;
        interval = cfg.scanInterval;
        scanDirectories = cfg.scanDirectories;
      };
      daemon.settings = {
        LogTime = true;
        LogVerbose = false;
        MaxScanSize = cfg.maxScanSize;
        MaxFileSize = cfg.maxFileSize;
        ExcludePath = cfg.excludePaths;
      };
    };

    systemd.services.clamdscan.serviceConfig = {
      CPUWeight = 20;
      IOWeight = 20;
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
    };
  };
}
''')

# ═══════════════════════════════════════════════════════
# 14. Netdata (Real-time Monitoring)
# ═══════════════════════════════════════════════════════
w("modules/80-monitoring/81-netdata.nix", '''\
# ---NIXMETA
# ---
# domain: 80
# id: "NIXH-80-MON-002"
# title: "Netdata (SRE Exhausted)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [netdata,monitoring,metrics,dbengine,real-time]
# description: "Real-time performance monitoring with dbengine retention and strict sandboxing."
# path: "modules/80-monitoring/81-netdata.nix"
# provides: [my.monitoring.netdata]
# requires: [10-network]
# links:
#   module: modules/80-monitoring/81-netdata.nix
#   source: _meta/80-monitoring/service-netdata.nix (NIXH-80-MON-002)
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.monitoring.netdata;
  port = config.my.ports.netdata or 10999;
  domain = config.my.configs.identity.domain or "m7c5.de";
in
{
  options.my.monitoring.netdata = {
    enable = lib.mkEnableOption "Netdata real-time monitoring";
    memoryMode = lib.mkOption { type = lib.types.str; default = "dbengine"; };
    pageCacheSize = lib.mkOption { type = lib.types.str; default = "256"; description = "Page cache size in MB."; };
    dbengineDiskSpace = lib.mkOption { type = lib.types.str; default = "4096"; description = "DBengine disk space in MB."; };
    retentionDays = lib.mkOption { type = lib.types.int; default = 30; };
    history = lib.mkOption { type = lib.types.int; default = 86400; };
    memoryMax = lib.mkOption { type = lib.types.str; default = "1G"; };
    cpuWeight = lib.mkOption { type = lib.types.int; default = 50; };
  };

  config = lib.mkIf cfg.enable {
    services.netdata = {
      enable = true;
      config = {
        global = {
          "memory mode" = cfg.memoryMode;
          "page cache size" = cfg.pageCacheSize;
          "dbengine disk space" = cfg.dbengineDiskSpace;
          "history" = cfg.history;
        };
        web = {
          "allow connections from" = "localhost 127.0.0.1";
          "default port" = toString port;
          "mode" = "static-threaded";
        };
        db = {
          "dbengine tier 1 retention days" = cfg.retentionDays;
        };
        health.enabled = "yes";
      };
    };

    services.caddy.virtualHosts."netdata.${domain}" = {
      extraConfig = "import sso_auth\\nreverse_proxy 127.0.0.1:${toString port}";
    };

    systemd.services.netdata.serviceConfig = {
      ProtectSystem = lib.mkForce "full";
      ProtectHome = lib.mkForce true;
      PrivateTmp = lib.mkForce true;
      PrivateDevices = lib.mkForce true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = [ "CAP_DAC_READ_SEARCH" "CAP_SYS_PTRACE" "CAP_NET_RAW" ];
      AmbientCapabilities = [ "CAP_DAC_READ_SEARCH" "CAP_SYS_PTRACE" "CAP_NET_RAW" ];
      MemoryMax = cfg.memoryMax;
      CPUWeight = cfg.cpuWeight;
      OOMScoreAdjust = 1000;
    };
  };
}
''')

# ═══════════════════════════════════════════════════════
# 15. Scrutiny (S.M.A.R.T Monitoring)
# ═══════════════════════════════════════════════════════
w("modules/80-monitoring/82-scrutiny.nix", '''\
# ---NIXMETA
# ---
# domain: 80
# id: "NIXH-80-MON-003"
# title: "Scrutiny (SRE Hardened)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [scrutiny,smart,monitoring,hardware,health]
# description: "Drive S.M.A.R.T monitoring with InfluxDB trends and strict sandboxing."
# path: "modules/80-monitoring/82-scrutiny.nix"
# provides: [my.monitoring.scrutiny]
# requires: [10-network]
# links:
#   module: modules/80-monitoring/82-scrutiny.nix
# source: _meta/80-monitoring/service-scrutiny.nix (NIXH-80-MON-003)
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.monitoring.scrutiny;
  port = config.my.ports.scrutiny or 20007;
  domain = config.my.configs.identity.domain or "m7c5.de";
in
{
  options.my.monitoring.scrutiny = {
    enable = lib.mkEnableOption "Scrutiny S.M.A.R.T monitoring";
    logLevel = lib.mkOption { type = lib.types.enum [ "DEBUG" "INFO" "WARNING" "ERROR" ]; default = "INFO"; };
  };

  config = lib.mkIf cfg.enable {
    services.scrutiny = {
      enable = true;
      settings = {
        web.listen.port = port;
        web.listen.host = "127.0.0.1";
        log.level = cfg.logLevel;
      };
      influxdb.enable = true;
      collector = {
        enable = true;
        schedule = "daily";
      };
    };

    services.caddy.virtualHosts."scrutiny.${domain}" = {
      extraConfig = "import sso_auth\\nreverse_proxy 127.0.0.1:${toString port}";
    };

    systemd.services.scrutiny.serviceConfig = {
      DynamicUser = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      OOMScoreAdjust = 800;
    };

    services.smartd.enable = true;
  };
}
''')

# ═══════════════════════════════════════════════════════
# 16. Uptime Kuma
# ═══════════════════════════════════════════════════════
w("modules/80-monitoring/83-uptime-kuma.nix", '''\
# ---NIXMETA
# ---
# domain: 80
# id: "NIXH-80-MON-004"
# title: "Uptime Kuma (SRE Exhausted)"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [uptime-kuma,monitoring,uptime,dashboard]
# description: "Self-hosted uptime monitoring with strict sandboxing and resource limits."
# path: "modules/80-monitoring/83-uptime-kuma.nix"
# provides: [my.monitoring.uptimeKuma]
# requires: [10-network]
# links:
#   module: modules/80-monitoring/83-uptime-kuma.nix
# source: _meta/80-monitoring/uptime-kuma.nix (NIXH-80-MON-004)
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.monitoring.uptimeKuma;
  port = config.my.ports.uptimeKuma or 10001;
  domain = config.my.configs.identity.domain or "m7c5.de";
in
{
  options.my.monitoring.uptimeKuma = {
    enable = lib.mkEnableOption "Uptime Kuma monitoring";
  };

  config = lib.mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;
      settings.PORT = toString port;
    };

    services.caddy.virtualHosts."status.${domain}" = {
      extraConfig = "import sso_auth\\nreverse_proxy 127.0.0.1:${toString port}";
    };

    systemd.services.uptime-kuma.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = [ "CAP_NET_RAW" ];
      AmbientCapabilities = [ "CAP_NET_RAW" ];
      MemoryMax = "512M";
      CPUWeight = 30;
      OOMScoreAdjust = 500;
    };
  };
}
''')

# ═══════════════════════════════════════════════════════
# 17. Miniflux (RSS, Socket Activation)
# ═══════════════════════════════════════════════════════
w("modules/50-knowledge/51-miniflux.nix", '''\
# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-KNW-002"
# title: "Miniflux (SRE Exhausted)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [miniflux,rss,socket-activation,wake-on-access,sandboxing]
# description: "Minimalist RSS reader with Wake-on-Access (socket activation) and strict sandboxing."
# path: "modules/50-knowledge/51-miniflux.nix"
# provides: [my.knowledge.miniflux]
# requires: [10-network, 20-security]
# links:
#   module: modules/50-knowledge/51-miniflux.nix
# source: _meta/50-knowledge/service-app-miniflux.nix (NIXH-50-KNW-002)
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.knowledge.miniflux;
  port = config.my.ports.miniflux or 20008;
  domain = config.my.configs.identity.domain or "m7c5.de";
in
{
  options.my.knowledge.miniflux = {
    enable = lib.mkEnableOption "Miniflux RSS reader";
    adminUsername = lib.mkOption { type = lib.types.str; default = "admin"; };
    adminCredentialsFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/secrets/miniflux_admin_password";
      description = "Path to admin credentials file.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.miniflux = {
      enable = true;
      config = {
        LISTEN_ADDR = "fd://3";
        WATCHDOG = 1;
        RUN_MIGRATIONS = 1;
        ADMIN_USERNAME = cfg.adminUsername;
      };
      createDatabaseLocally = true;
      adminCredentialsFile = cfg.adminCredentialsFile;
    };

    # Wake-on-Access via socket activation
    systemd.sockets.miniflux = {
      description = "Miniflux Socket";
      wantedBy = [ "sockets.target" ];
      listenStreams = [ (toString port) ];
    };

    systemd.services.miniflux = {
      wantedBy = lib.mkForce [];
      requires = [ "miniflux.socket" ];
      after = [ "miniflux.socket" ];
      serviceConfig = {
        DynamicUser = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        SystemCallFilter = [ "@system-service" "~@privileged" ];
        OOMScoreAdjust = 500;
      };
    };
  };
}
''')

# ═══════════════════════════════════════════════════════
# 18. Linkwarden (Bookmarks, DynamicUser)
# ═══════════════════════════════════════════════════════
w("modules/50-knowledge/52-linkwarden.nix", '''\
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
      extraConfig = "import sso_auth\\nreverse_proxy 127.0.0.1:${toString port}";
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
''')

# ═══════════════════════════════════════════════════════
# 19. Matrix Conduit (Rust Homeserver)
# ═══════════════════════════════════════════════════════
w("modules/60-apps/64-matrix-conduit.nix", '''\
# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-005"
# title: "Matrix Conduit (SRE Hardened)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [matrix,conduit,homeserver,chat,sandboxing]
# description: "Lightweight Matrix homeserver (Conduit/Rust) with strict sandboxing."
# path: "modules/60-apps/64-matrix-conduit.nix"
# provides: [my.apps.matrixConduit]
# requires: [10-network, 20-security]
# links:
#   module: modules/60-apps/64-matrix-conduit.nix
# source: _meta/60-apps/service-app-matrix-conduit.nix (NIXH-60-APP-005)
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.apps.matrixConduit;
  port = config.my.ports.matrix or 20006;
  domain = config.my.configs.identity.domain or "m7c5.de";
  subdomain = config.my.configs.identity.subdomain or "nix";
  serverName = "matrix.${subdomain}.${domain}";
in
{
  options.my.apps.matrixConduit = {
    enable = lib.mkEnableOption "Matrix Conduit homeserver";
    allowRegistration = lib.mkOption { type = lib.types.bool; default = true; };
    databaseBackend = lib.mkOption {
      type = lib.types.enum [ "rocksdb" "sqlite" ];
      default = "rocksdb";
    };
    cpuWeight = lib.mkOption { type = lib.types.int; default = 50; };
    memoryMax = lib.mkOption { type = lib.types.str; default = "1G"; };
  };

  config = lib.mkIf cfg.enable {
    services.matrix-conduit = {
      enable = true;
      settings.global = {
        server_name = serverName;
        port = port;
        address = "127.0.0.1";
        database_backend = cfg.databaseBackend;
        allow_registration = cfg.allowRegistration;
      };
    };

    services.caddy.virtualHosts."${serverName}" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:${toString port}
        handle /.well-known/matrix/server {
          respond "{\\"m.server\\": \\"${serverName}:${toString port}\\"}" 200
        }
        handle /.well-known/matrix/client {
          respond "{\\"m.homeserver\\": {\\"base_url\\": \\"https://${serverName}\\"}}" 200
        }
      '';
    };

    systemd.services.conduit.serviceConfig = {
      StateDirectory = lib.mkForce "matrix-conduit";
      ReadWritePaths = lib.mkForce [ "/var/lib/matrix-conduit" ];
      MemoryDenyWriteExecute = lib.mkForce false;
      CPUWeight = lib.mkForce cfg.cpuWeight;
      MemoryMax = lib.mkForce cfg.memoryMax;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };
}
''')

# ═══════════════════════════════════════════════════════
# 20. Monica CRM
# ═══════════════════════════════════════════════════════
w("modules/60-apps/65-monica.nix", '''\
# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-006"
# title: "Monica CRM"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-21
# tags: [monica,crm,personal,relationships,php]
# description: "Personal CRM for managing relationships with strict sandboxing."
# path: "modules/60-apps/65-monica.nix"
# provides: [my.apps.monica]
# requires: [10-network, 20-security]
# links:
#   module: modules/60-apps/65-monica.nix
# source: _meta/60-apps/service-app-monica.nix (NIXH-60-APP-006)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
  cfg = config.my.apps.monica;
  port = config.my.ports.monica or 20004;
  domain = config.my.configs.identity.domain or "m7c5.de";
  appKeyFile = "/var/lib/monica/app-key";
in
{
  options.my.apps.monica = {
    enable = lib.mkEnableOption "Monica personal CRM";
  };

  config = lib.mkIf cfg.enable {
    services.monica = {
      enable = true;
      hostname = "monica.${domain}";
      appURL = "https://monica.${domain}";
      inherit appKeyFile;
      nginx.listen = [ { addr = "127.0.0.1"; port = port; ssl = false; } ];
      database.createLocally = true;
    };

    services.caddy.virtualHosts."monica.${domain}" = {
      extraConfig = "import sso_auth\\nreverse_proxy 127.0.0.1:${toString port}";
    };

    # Generate app key if not exists
    system.activationScripts.monicaAppKeyFile.text = ''
      install -d -m 0750 -o monica -g monica /var/lib/monica
      if [ ! -s ${appKeyFile} ]; then
        head -c 32 /dev/urandom | base64 > ${appKeyFile}
      fi
    '';

    systemd.services.phpfpm-monica.serviceConfig = {
      ProtectSystem = lib.mkForce "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ReadWritePaths = [ "/var/lib/monica" ];
    };
  };
}
''')

# ═══════════════════════════════════════════════════════
# 21. CouchDB
# ═══════════════════════════════════════════════════════
w("modules/60-apps/66-couchdb.nix", '''\
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
''')

# ═══════════════════════════════════════════════════════
# 22. Filebrowser
# ═══════════════════════════════════════════════════════
w("modules/60-apps/67-filebrowser.nix", '''\
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
      extraConfig = "import sso_auth\\nreverse_proxy 127.0.0.1:${toString port}";
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
''')

# ═══════════════════════════════════════════════════════
# 23. Karakeep (Bookmarks)
# ═══════════════════════════════════════════════════════
w("modules/50-knowledge/53-karakeep.nix", '''\
# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-60-APP-004"
# title: "Karakeep (SRE Hardened)"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [karakeep,bookmarks,web-app,sandboxing]
# description: "Bookmark management tool with SRE sandboxing."
# path: "modules/50-knowledge/53-karakeep.nix"
# provides: [my.knowledge.karakeep]
# requires: [10-network]
# links:
#   module: modules/50-knowledge/53-karakeep.nix
# source: _meta/60-apps/service-app-karakeep.nix (NIXH-60-APP-004)
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.knowledge.karakeep;
  port = config.my.ports.karakeep or 20003;
  domain = config.my.configs.identity.domain or "m7c5.de";
in
{
  options.my.knowledge.karakeep = {
    enable = lib.mkEnableOption "Karakeep bookmark manager";
    disableSignups = lib.mkOption { type = lib.types.bool; default = true; };
  };

  config = lib.mkIf cfg.enable {
    services.karakeep = {
      enable = true;
      extraEnvironment = {
        PORT = toString port;
        DISABLE_SIGNUPS = if cfg.disableSignups then "true" else "false";
      };
    };

    services.caddy.virtualHosts."bookmarks.${domain}" = {
      extraConfig = "import sso_auth\\nreverse_proxy 127.0.0.1:${toString port}";
    };
  };
}
''')

# ═══════════════════════════════════════════════════════
# 24. Ollama / AI Agents
# ═══════════════════════════════════════════════════════
w("modules/30-automation/31-ai-agents.nix", '''\
# ---NIXMETA
# ---
# domain: 30
# id: "NIXH-30-AUT-002"
# title: "AI Agents (Ollama & Claude)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [ai,ollama,claude-code,gpu,local-llm]
# description: "Local AI orchestration with Ollama (GPU-accelerated) and Claude Code integration."
# path: "modules/30-automation/31-ai-agents.nix"
# provides: [my.automation.aiAgents]
# requires: [00-core]
# links:
#   module: modules/30-automation/31-ai-agents.nix
# source: _meta/30-automation/service-app-ai-agents.nix (NIXH-30-AUT-002)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
  cfg = config.my.automation.aiAgents;
in
{
  options.my.automation.aiAgents = {
    enable = lib.mkEnableOption "Local AI (Ollama + Claude Code)";
    models = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "llama3.1:8b" ];
      description = "Models to pre-load.";
    };
    useVulkan = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use Vulkan for Intel iGPU acceleration.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = if cfg.useVulkan then pkgs.ollama-vulkan else pkgs.ollama;
      loadModels = cfg.models;
    };

    systemd.services.ollama.serviceConfig = {
      DeviceAllow = [ "/dev/dri/renderD128 rw" ];
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      OOMScoreAdjust = 500;
    };
  };
}
''')

# ═══════════════════════════════════════════════════════
# 25. OliveTin (Web Shell)
# ═══════════════════════════════════════════════════════
w("modules/30-automation/32-olivetin.nix", '''\
# ---NIXMETA
# ---
# domain: 30
# id: "NIXH-30-AUT-005"
# title: "OliveTin (Web Shell)"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [olivetin,web-shell,automation,runbook]
# description: "Web shell for safe command execution with predefined actions."
# path: "modules/30-automation/32-olivetin.nix"
# provides: [my.automation.olivetin]
# requires: [10-network]
# links:
#   module: modules/30-automation/32-olivetin.nix
# source: _meta/30-automation/service-app-olivetin.nix (NIXH-30-AUT-005)
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.automation.olivetin;
  port = config.my.ports.olivetin or 10080;
  domain = config.my.configs.identity.domain or "m7c5.de";
in
{
  options.my.automation.olivetin = {
    enable = lib.mkEnableOption "OliveTin web shell";
    configPath = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nixos/olivetin-config.yaml";
      description = "Path to OliveTin config file.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.olivetin = {
      enable = true;
      port = port;
      inherit (cfg) configPath;
    };

    services.caddy.virtualHosts."shell.${domain}" = {
      extraConfig = "import sso_auth\\nreverse_proxy 127.0.0.1:${toString port}";
    };

    systemd.services.olivetin.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
      OOMScoreAdjust = 200;
    };
  };
}
''')

# ═══════════════════════════════════════════════════════
# 26. Media Stack (ABC Tiering Layout)
# ═══════════════════════════════════════════════════════
w("modules/50-media/52-media-stack.nix", '''\
# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-40-MED-001"
# title: "Media Stack (Exhausted Layout)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [media-stack,abc-tiering,tmpfiles,permissions,media-group]
# description: "Canonical media/state layout with ABC-tiering enforcement and global media permissions."
# path: "modules/50-media/52-media-stack.nix"
# provides: [my.media.stack]
# requires: [30-storage]
# links:
#   module: modules/50-media/52-media-stack.nix
# source: _meta/40-media/media-stack.nix (NIXH-40-MED-001)
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.media.stack;
  mediaLib = cfg.mediaLibrary;
  storagePool = cfg.storagePool;
  stateDir = cfg.stateDir;
in
{
  options.my.media.stack = {
    enable = lib.mkEnableOption "Media stack layout with ABC tiering";
    mediaLibrary = lib.mkOption { type = lib.types.str; default = "/mnt/media"; };
    storagePool = lib.mkOption { type = lib.types.str; default = "/mnt/fast-pool"; };
    stateDir = lib.mkOption { type = lib.types.str; default = "/data/state"; };
    mediaGid = lib.mkOption { type = lib.types.int; default = 169; description = "GID for media group."; };
  };

  config = lib.mkIf cfg.enable {
    users.groups.media = {
      gid = cfg.mediaGid;
      members = [ "jellyfin" "sabnzbd" "audiobookshelf" "sonarr" "radarr" "lidarr" "readarr" "prowlarr" ];
    };

    systemd.tmpfiles.rules = [
      "d ${mediaLib} 0775 root media -"
      "d ${mediaLib}/movies 0775 radarr media -"
      "d ${mediaLib}/tv 0775 sonarr media -"
      "d ${mediaLib}/music 0775 lidarr media -"
      "d ${mediaLib}/books 0775 readarr media -"
      "d ${mediaLib}/documents 0775 paperless media -"
      "d ${storagePool}/downloads 0775 root media -"
      "d ${storagePool}/downloads/torrents 0775 prowlarr media -"
      "d ${storagePool}/downloads/usenet 0775 sabnzbd media -"
      "d ${stateDir} 0755 root root -"
      "d ${storagePool}/metadata 0775 root media -"
      "d ${storagePool}/cache 0775 root media -"
    ];
  };
}
''')

# ═══════════════════════════════════════════════════════
# 27. VPN Confinement (Network Namespace)
# ═══════════════════════════════════════════════════════
w("modules/10-network/21-vpn-confinement.nix", '''\
# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-20-INF-007"
# title: "VPN Confinement"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-21
# tags: [vpn,network-namespace,wireguard,isolation,confinement]
# description: "Network namespace based VPN isolation for secure service routing."
# path: "modules/10-network/21-vpn-confinement.nix"
# provides: [my.networking.vpnConfinement]
# requires: [10-network]
# links:
#   module: modules/10-network/21-vpn-confinement.nix
# source: _meta/20-infrastructure/vpn-confinement.nix (NIXH-20-INF-007)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
  cfg = config.my.networking.vpnConfinement;
  nsName = cfg.namespaceName;
  hostIP = cfg.hostIP;
  vaultIP = cfg.vaultIP;
  wgKey = cfg.wgPrivateKeyFile;
  vpnConfig = cfg.vpn;
in
{
  options.my.networking.vpnConfinement = {
    enable = lib.mkEnableOption "VPN network namespace isolation";
    namespaceName = lib.mkOption { type = lib.types.str; default = "media-vault"; };
    hostIP = lib.mkOption { type = lib.types.str; default = "10.200.1.1"; };
    vaultIP = lib.mkOption { type = lib.types.str; default = "10.200.1.2"; };
    wgPrivateKeyFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/secrets/wg_privado_private_key";
      description = "Path to WireGuard private key file.";
    };
    vpn = {
      publicKey = lib.mkOption { type = lib.types.str; default = ""; };
      endpoint = lib.mkOption { type = lib.types.str; default = ""; };
      address = lib.mkOption { type = lib.types.str; default = ""; };
      dns = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      { assertion = vpnConfig.dns != []; message = "vpn-confinement: DNS must not be empty."; }
      { assertion = vpnConfig.publicKey != ""; message = "vpn-confinement: publicKey must be set."; }
    ];

    systemd.services."netns-${nsName}" = {
      description = "Network Namespace: ${nsName}";
      before = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "setup-vault-ns" ''
          ip netns add ${nsName} || true
          ip link add veth-${nsName} type veth peer name veth-${nsName}-ns
          ip link set veth-${nsName} up
          ip link set veth-${nsName}-ns netns ${nsName}
          ip addr add ${hostIP}/30 dev veth-${nsName}
          ip netns exec ${nsName} ip addr add ${vaultIP}/30 dev veth-${nsName}-ns
          ip netns exec ${nsName} ip link set veth-${nsName}-ns up
          ip netns exec ${nsName} ip link set lo up
          ip netns exec ${nsName} ip route add default via ${hostIP}
          iptables -t nat -A POSTROUTING -s ${vaultIP}/30 -o eth0 -j MASQUERADE
          echo 1 > /proc/sys/net/ipv4/ip_forward
        '';
      };
    };

    systemd.services.wireguard-vault = {
      description = "WireGuard VPN inside ${nsName}";
      after = [ "netns-${nsName}.service" "network-online.target" ];
      requires = [ "netns-${nsName}.service" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "30s";
      };
      path = [ pkgs.wireguard-tools pkgs.coreutils pkgs.iproute2 ];
      script = ''
        set -euo pipefail
        ip netns exec ${nsName} wg addconf wg0 ${wgKey}
        ip netns exec ${nsName} ip addr add ${vpnConfig.address} dev wg0
        ip netns exec ${nsName} ip link set wg0 up
        ip netns exec ${nsName} ip route add 0.0.0.0/0 dev wg0 2>/dev/null || true
      '';
    };
  };
}
''')

# ═══════════════════════════════════════════════════════
# 28. Security Assertions (SRE Compliance)
# ═══════════════════════════════════════════════════════
w("modules/90-policy/91-security-assertions.nix", '''\
# ---NIXMETA
# ---
# domain: 90
# id: "NIXH-90-POL-004"
# title: "Security Assertions"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [security,assertions,compliance,firewall,ssh]
# description: "Global security assertions to ensure critical hardening settings are active."
# path: "modules/90-policy/91-security-assertions.nix"
# provides: [my.policy.securityAssertions]
# requires: [00-core]
# links:
#   module: modules/90-policy/91-security-assertions.nix
# source: _meta/90-policy/security-assertions.nix (NIXH-90-POL-004)
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.policy.securityAssertions;
  must = assertion: message: { inherit assertion message; };
  sshSettings = config.services.openssh.settings;
in
{
  options.my.policy.securityAssertions = {
    enable = lib.mkEnableOption "Security assertion enforcement";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (must (config.networking.firewall.enable == true) "[SEC-NET-001] Firewall must be active.")
      (must (config.networking.nftables.enable == true) "[SEC-NET-002] NFTables must be enabled.")
      (must (sshSettings.PermitRootLogin == "no") "[SEC-SSH-002] Root SSH login must be disabled.")
    ];
  };
}
''')

print("\n✅ Phase 2 complete: 18 additional modules written (28 total mined).")
