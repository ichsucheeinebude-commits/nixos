# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-003"
# title: "n8n Automation"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-21
# tags: [apps,n8n,automation,webhooks,workflows]
# description: "n8n workflow automation with full option interface from MASTER-CONFIG."
# path: "modules/60-apps/61-n8n.nix"
# provides: [my.apps.n8n]
# requires: [10-network, 30-storage]
# links:
#   adr: docs/adr/ADR-61-n8n.md
#   guide: docs/guides/61-n8n.md
#   module: modules/60-apps/61-n8n.nix
# source: guides/MASTER-CONFIG-N8N.md
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
let
  cfg = config.my.apps.n8n;
in
{
  options.my.apps.n8n = {
    enable = lib.mkEnableOption "n8n workflow automation platform";

    # ── Network ──
    baseUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Public base URL (e.g., https://n8n.m7c5.de)";
    };
    listenPort = lib.mkOption {
      type = lib.types.port;
      default = 5678;
      description = "Port for n8n web interface.";
    };
    editorUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "External editor URL if different from baseUrl.";
    };
    webhookUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Webhook URL for external triggers.";
    };

    # ── Database ──
    dbType = lib.mkOption {
      type = lib.types.enum [ "sqlite" "postgresdb" "mysqldb" "mariadb" ];
      default = "sqlite";
      description = "Database type.";
    };
    dbPostgresHost = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "PostgreSQL host.";
    };
    dbPostgresPort = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
      description = "PostgreSQL port.";
    };
    dbPostgresDatabase = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "PostgreSQL database name.";
    };
    dbPostgresUser = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "PostgreSQL user.";
    };
    dbPostgresPasswordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to file containing PostgreSQL password (via SOPS).";
    };
    dbPostgresPoolSize = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "PostgreSQL connection pool size.";
    };
    dbPostgresSchema = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "PostgreSQL schema.";
    };
    dbTablePrefix = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Prefix for database tables.";
    };

    # ── Security ──
    encryptionKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to file containing encryption key (via SOPS).";
    };
    blockEnvAccessInNode = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Block environment variable access in nodes.";
    };
    restrictFileAccessTo = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Restrict file access to a specific directory path.";
    };
    hmacSignatureSecretFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to file containing HMAC signature secret (via SOPS).";
    };
    binaryDataSigningSecretFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to file containing binary data signing secret (via SOPS).";
    };

    # ── Data ──
    userFolder = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/n8n";
      description = "n8n user data directory.";
    };
    binaryDataStoragePath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path for binary data storage.";
    };
    defaultBinaryDataMode = lib.mkOption {
      type = lib.types.enum [ "default" "filesystem" "s3" ];
      default = "default";
      description = "Default binary data storage mode.";
    };
    executionDataStorageMode = lib.mkOption {
      type = lib.types.enum [ "default" "filesystem" ];
      default = "default";
      description = "Execution data storage mode.";
    };

    # ── Execution ──
    expressionEngine = lib.mkOption {
      type = lib.types.enum [ "evaluate" "tournament" ];
      default = "evaluate";
      description = "Expression engine to use.";
    };
    minimizeExecutionDataFetching = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Minimize execution data fetching for performance.";
    };
    executionsProcess = lib.mkOption {
      type = lib.types.enum [ "own" "main" ];
      default = "main";
      description = "Execution process mode.";
    };

    # ── Features ──
    personalizationEnabled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable personalization/survey on first login.";
    };
    publicApiDisabled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Disable the public API.";
    };
    aiEnabled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable AI features.";
    };
    aiAnthropicKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to file containing Anthropic API key (via SOPS).";
    };

    # ── Node Function Access ──
    nodeFunctionAllowBuiltin = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of allowed builtin Node.js modules.";
    };
    nodeFunctionAllowExternal = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of allowed external npm packages.";
    };

    # ── Nodes ──
    nodesExclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of node types to exclude.";
    };
    disabledModules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of modules to disable.";
    };
    enabledModules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of modules to enable.";
    };

    # ── Timezone ──
    timezone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Berlin";
      description = "Generic timezone for n8n.";
    };

    # ── External modules ──
    nodePath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "NODE_PATH for external node modules.";
    };

    # ── Observability ──
    sentryDsn = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Sentry DSN for error tracking.";
    };
    enableObservability = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable observability features.";
    };

    # ── Security Hardening ──
    enforceSettingsFilePermissions = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enforce strict file permissions on settings files.";
    };
    runnerInsecureMode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Run code runners in insecure mode (not recommended).";
    };
  };

  config = lib.mkIf cfg.enable {
    services.n8n = {
      enable = true;
      port = cfg.listenPort;

      settings = {
        N8N_BASE_URL = lib.mkIf (cfg.baseUrl != null) cfg.baseUrl;
        N8N_EDITOR_URL = lib.mkIf (cfg.editorUrl != null) cfg.editorUrl;
        WEBHOOK_URL = lib.mkIf (cfg.webhookUrl != null) cfg.webhookUrl;
        DB_TYPE = cfg.dbType;
        DB_POSTGRESDB_HOST = lib.mkIf (cfg.dbPostgresHost != null) cfg.dbPostgresHost;
        DB_POSTGRESDB_PORT = lib.mkIf (cfg.dbPostgresPort != null) (toString cfg.dbPostgresPort);
        DB_POSTGRESDB_DATABASE = lib.mkIf (cfg.dbPostgresDatabase != null) cfg.dbPostgresDatabase;
        DB_POSTGRESDB_USER = lib.mkIf (cfg.dbPostgresUser != null) cfg.dbPostgresUser;
        DB_POSTGRESDB_POOL_SIZE = lib.mkIf (cfg.dbPostgresPoolSize != null) (toString cfg.dbPostgresPoolSize);
        DB_POSTGRESDB_SCHEMA = lib.mkIf (cfg.dbPostgresSchema != null) cfg.dbPostgresSchema;
        DB_TABLE_PREFIX = lib.mkIf (cfg.dbTablePrefix != null) cfg.dbTablePrefix;
        N8N_BLOCK_ENV_ACCESS_IN_NODE = if cfg.blockEnvAccessInNode then "true" else "false";
        N8N_RESTRICT_FILE_ACCESS_TO = lib.mkIf (cfg.restrictFileAccessTo != null) cfg.restrictFileAccessTo;
        N8N_USER_FOLDER = cfg.userFolder;
        N8N_BINARY_DATA_STORAGE_PATH = lib.mkIf (cfg.binaryDataStoragePath != null) cfg.binaryDataStoragePath;
        N8N_DEFAULT_BINARY_DATA_MODE = cfg.defaultBinaryDataMode;
        N8N_EXECUTION_DATA_STORAGE_MODE = cfg.executionDataStorageMode;
        N8N_EXPRESSION_ENGINE = cfg.expressionEngine;
        N8N_MINIMIZE_EXECUTION_DATA_FETCHING = if cfg.minimizeExecutionDataFetching then "true" else "false";
        EXECUTIONS_PROCESS = cfg.executionsProcess;
        N8N_PERSONALIZATION_ENABLED = if cfg.personalizationEnabled then "true" else "false";
        N8N_PUBLIC_API_DISABLED = if cfg.publicApiDisabled then "true" else "false";
        N8N_AI_ENABLED = if cfg.aiEnabled then "true" else "false";
        NODE_FUNCTION_ALLOW_BUILTIN = lib.mkIf (cfg.nodeFunctionAllowBuiltin != [])
          (lib.concatStringsSep "," cfg.nodeFunctionAllowBuiltin);
        NODE_FUNCTION_ALLOW_EXTERNAL = lib.mkIf (cfg.nodeFunctionAllowExternal != [])
          (lib.concatStringsSep "," cfg.nodeFunctionAllowExternal);
        NODES_EXCLUDE = lib.mkIf (cfg.nodesExclude != [])
          (lib.concatStringsSep "," cfg.nodesExclude);
        N8N_DISABLED_MODULES = lib.mkIf (cfg.disabledModules != [])
          (lib.concatStringsSep "," cfg.disabledModules);
        N8N_ENABLED_MODULES = lib.mkIf (cfg.enabledModules != [])
          (lib.concatStringsSep "," cfg.enabledModules);
        GENERIC_TIMEZONE = cfg.timezone;
        N8N_NODE_PATH = lib.mkIf (cfg.nodePath != null) cfg.nodePath;
        N8N_SENTRY_DSN = lib.mkIf (cfg.sentryDsn != null) cfg.sentryDsn;
        N8N_ENABLE_OBSERVABILITY = if cfg.enableObservability then "true" else "false";
        N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS = if cfg.enforceSettingsFilePermissions then "true" else "false";
        N8N_RUNNERS_INSECURE_MODE = if cfg.runnerInsecureMode then "true" else "false";
      };

      # Secrets via environmentFile
      extraEnv = {
        N8N_ENCRYPTION_KEY_FILE = lib.mkIf (cfg.encryptionKeyFile != null) cfg.encryptionKeyFile;
        N8N_HMAC_SIGNATURE_SECRET_FILE = lib.mkIf (cfg.hmacSignatureSecretFile != null) cfg.hmacSignatureSecretFile;
      };
    };

    # ── Systemd Hardening ──
    systemd.services.n8n.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [ cfg.userFolder ]
        ++ lib.optionals (cfg.binaryDataStoragePath != null) [ cfg.binaryDataStoragePath ];
      # n8n security: block env access by default
      RestrictNamespaces = true;
      LockPersonality = true;
    };
  };
}
