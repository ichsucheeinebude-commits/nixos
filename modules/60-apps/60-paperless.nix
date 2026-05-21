# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-001"
# title: "Paperless-ngx"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-21
# tags: [apps,paperless,document-management,ocr]
# description: "Paperless-ngx document management system with full option interface from MASTER-CONFIG."
# path: "modules/60-apps/60-paperless.nix"
# provides: [my.apps.paperless]
# requires: [30-storage, 10-network]
# links:
#   adr: docs/adr/ADR-60-paperless.md
#   guide: docs/guides/60-paperless.md
#   module: modules/60-apps/60-paperless.nix
# source: guides/MASTER-CONFIG-PAPERLESS-NGX.md
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
let
  cfg = config.my.apps.paperless;
in
{
  options.my.apps.paperless = {
    enable = lib.mkEnableOption "Paperless-ngx document management system";

    # ── Network ──
    url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Public URL of the Paperless instance (e.g., https://paperless.m7c5.de)";
    };
    allowedHosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "localhost" "127.0.0.1" ];
      description = "Allowed hosts for HTTP requests.";
    };
    corsAllowedHosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Allowed CORS origins.";
    };
    csrfTrustedOrigins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Trusted origins for CSRF validation.";
    };

    # ── Storage ──
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/paperless";
      description = "Main data directory for Paperless.";
    };
    mediaRoot = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Media root directory. Defaults to dataDir/media.";
    };
    consumptionDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/paperless/consume";
      description = "Directory monitored for new documents to consume.";
    };
    staticDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Static files directory.";
    };
    emptyTrashDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Directory for permanently deleted documents.";
    };

    # ── Database ──
    dbHost = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Database host. Null means SQLite (recommended for single-user).";
    };
    dbName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Database name.";
    };
    dbUser = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Database username.";
    };
    dbPort = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "Database port.";
    };
    dbSslMode = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Database SSL mode.";
    };

    # ── OCR ──
    ocrLanguage = lib.mkOption {
      type = lib.types.str;
      default = "deu+eng";
      description = "OCR language(s) to use.";
    };
    ocrMode = lib.mkOption {
      type = lib.types.str;
      default = "clean";
      description = "OCR mode: clean, skip, force, redo, skip_noarchive.";
    };
    ocrOutputType = lib.mkOption {
      type = lib.types.str;
      default = "pdfa";
      description = "OCR output type: pdfa, pdf.";
    };
    ocrPages = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = "Number of pages to OCR. 0 = all pages.";
    };
    ocrDeskeq = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to deskew pages during OCR.";
    };
    ocrClean = lib.mkOption {
      type = lib.types.str;
      default = "clean";
      description = "OCR clean level: clean, clean-final, none.";
    };
    ocrRotatePages = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically rotate pages during OCR.";
    };
    ocrRotatePagesThreshold = lib.mkOption {
      type = lib.types.int;
      default = 12;
      description = "Confidence threshold for auto-rotation.";
    };
    ocrImageDpi = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "DPI to use for OCR. Null = auto-detect.";
    };
    ocrSkipArchiveFile = lib.mkOption {
      type = lib.types.str;
      default = "keep";
      description = "Whether to skip archiving the original file: keep, archive, skip.";
    };

    # ── Consumer ──
    consumerPollingInterval = lib.mkOption {
      type = lib.types.int;
      default = 5;
      description = "Polling interval (seconds) for consumption directory.";
    };
    consumerRecursive = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to scan subdirectories recursively.";
    };
    consumerDeleteDuplicates = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Delete duplicate documents on consume.";
    };
    consumerEnableBarcodes = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable barcode scanning on documents.";
    };
    consumerEnableCollateDoubleSided = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable double-sided document collation.";
    };
    consumerSubdirsAsTags = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use subdirectory names as tags.";
    };
    consumerIgnorePatterns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Patterns to ignore in consumption directory.";
    };

    # ── Filename ──
    filenameFormat = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "{{created_year}}/{{correspondent}}/{{title}}";
      description = "Format string for stored filenames.";
    };
    filenameDateOrder = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Date order for filename parsing (YMD, MDY, DMY).";
    };

    # ── Performance ──
    taskWorkers = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Number of Celery task workers.";
    };
    threadsPerWorker = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Threads per task worker.";
    };
    redisUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Redis connection URL for task queue.";
    };

    # ── Security ──
    enableUpdateCheck = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable upstream update checks.";
    };
    secretKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to file containing Django secret key (via SOPS).";
    };

    # ── TIKA (document parsing) ──
    tikaEnabled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Apache TIKA for document parsing.";
    };
    tikaEndpoint = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "TIKA server endpoint URL.";
    };
    tikaGotenbergEndpoint = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Gotenberg server endpoint for TIKA.";
    };

    # ── Misc ──
    timezone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Berlin";
      description = "Timezone for the application.";
    };
    autoLoginUsername = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Username for auto-login (local access only, do NOT use with public access).";
    };
    enableHttpRemoteUser = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable HTTP remote user authentication (for reverse proxy auth).";
    };
    cookiePrefix = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Cookie name prefix.";
    };
    forceScriptName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Force SCRIPT_NAME for reverse proxy setups.";
    };
    staticUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Static URL prefix.";
    };
    postConsumeScript = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Script to run after successful document consumption.";
    };
    preConsumeScript = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Script to run before document consumption.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.paperless = {
      enable = true;
      address = "0.0.0.0";
      port = 28981;
      dataDir = cfg.dataDir;
      consumptionDir = cfg.consumptionDir;
      mediaDir = cfg.mediaRoot;

      settings = {
        PAPERLESS_URL = lib.mkIf (cfg.url != null) cfg.url;
        PAPERLESS_ALLOWED_HOSTS = lib.concatStringsSep "," cfg.allowedHosts;
        PAPERLESS_CORS_ALLOWED_HOSTS = lib.mkIf (cfg.corsAllowedHosts != [])
          (lib.concatStringsSep "," cfg.corsAllowedHosts);
        PAPERLESS_CSRF_TRUSTED_ORIGINS = lib.mkIf (cfg.csrfTrustedOrigins != [])
          (lib.concatStringsSep "," cfg.csrfTrustedOrigins);
        PAPERLESS_DATA_DIR = cfg.dataDir;
        PAPERLESS_CONSUMPTION_DIR = cfg.consumptionDir;
        PAPERLESS_MEDIA_ROOT = lib.mkIf (cfg.mediaRoot != null) cfg.mediaRoot;
        PAPERLESS_STATICDIR = lib.mkIf (cfg.staticDir != null) cfg.staticDir;
        PAPERLESS_EMPTY_TRASH_DIR = lib.mkIf (cfg.emptyTrashDir != null) cfg.emptyTrashDir;

        # Database
        PAPERLESS_DBHOST = lib.mkIf (cfg.dbHost != null) cfg.dbHost;
        PAPERLESS_DBNAME = lib.mkIf (cfg.dbName != null) cfg.dbName;
        PAPERLESS_DBUSER = lib.mkIf (cfg.dbUser != null) cfg.dbUser;
        PAPERLESS_DBPORT = lib.mkIf (cfg.dbPort != null) (toString cfg.dbPort);
        PAPERLESS_DBSSLMODE = lib.mkIf (cfg.dbSslMode != null) cfg.dbSslMode;

        # OCR
        PAPERLESS_OCR_LANGUAGE = cfg.ocrLanguage;
        PAPERLESS_OCR_MODE = cfg.ocrMode;
        PAPERLESS_OCR_OUTPUT_TYPE = cfg.ocrOutputType;
        PAPERLESS_OCR_PAGES = toString cfg.ocrPages;
        PAPERLESS_OCR_DESKEW = if cfg.ocrDeskeq then "true" else "false";
        PAPERLESS_OCR_CLEAN = cfg.ocrClean;
        PAPERLESS_OCR_ROTATE_PAGES = if cfg.ocrRotatePages then "true" else "false";
        PAPERLESS_OCR_ROTATE_PAGES_THRESHOLD = toString cfg.ocrRotatePagesThreshold;
        PAPERLESS_OCR_IMAGE_DPI = lib.mkIf (cfg.ocrImageDpi != null) (toString cfg.ocrImageDpi);
        PAPERLESS_OCR_SKIP_ARCHIVE_FILE = cfg.ocrSkipArchiveFile;

        # Consumer
        PAPERLESS_CONSUMER_POLLING_INTERVAL = toString cfg.consumerPollingInterval;
        PAPERLESS_CONSUMER_RECURSIVE = if cfg.consumerRecursive then "true" else "false";
        PAPERLESS_CONSUMER_DELETE_DUPLICATES = if cfg.consumerDeleteDuplicates then "true" else "false";
        PAPERLESS_CONSUMER_ENABLE_BARCODES = if cfg.consumerEnableBarcodes then "true" else "false";
        PAPERLESS_CONSUMER_ENABLE_COLLATE_DOUBLE_SIDED =
          if cfg.consumerEnableCollateDoubleSided then "true" else "false";
        PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = if cfg.consumerSubdirsAsTags then "true" else "false";
        PAPERLESS_CONSUMER_IGNORE_PATTERNS = lib.mkIf (cfg.consumerIgnorePatterns != [])
          (lib.concatStringsSep "," cfg.consumerIgnorePatterns);

        # Filename
        PAPERLESS_FILENAME_FORMAT = lib.mkIf (cfg.filenameFormat != null) cfg.filenameFormat;
        PAPERLESS_FILENAME_DATE_ORDER = lib.mkIf (cfg.filenameDateOrder != null) cfg.filenameDateOrder;

        # Performance
        PAPERLESS_TASK_WORKERS = toString cfg.taskWorkers;
        PAPERLESS_THREADS_PER_WORKER = toString cfg.threadsPerWorker;
        PAPERLESS_REDIS = lib.mkIf (cfg.redisUrl != null) cfg.redisUrl;

        # Security
        PAPERLESS_ENABLE_UPDATE_CHECK = if cfg.enableUpdateCheck then "true" else "false";

        # TIKA
        PAPERLESS_TIKA_ENABLED = if cfg.tikaEnabled then "true" else "false";
        PAPERLESS_TIKA_ENDPOINT = lib.mkIf cfg.tikaEnabled (cfg.tikaEndpoint or "http://localhost:9998");
        PAPERLESS_TIKA_GOTENBERG_ENDPOINT = lib.mkIf cfg.tikaEnabled (cfg.tikaGotenbergEndpoint or "http://localhost:3000");

        # Misc
        PAPERLESS_TIME_ZONE = cfg.timezone;
        PAPERLESS_AUTO_LOGIN_USERNAME = lib.mkIf (cfg.autoLoginUsername != null) cfg.autoLoginUsername;
        PAPERLESS_ENABLE_HTTP_REMOTE_USER = if cfg.enableHttpRemoteUser then "true" else "false";
        PAPERLESS_COOKIE_PREFIX = lib.mkIf (cfg.cookiePrefix != null) cfg.cookiePrefix;
        PAPERLESS_FORCE_SCRIPT_NAME = lib.mkIf (cfg.forceScriptName != null) cfg.forceScriptName;
        PAPERLESS_STATIC_URL = lib.mkIf (cfg.staticUrl != null) cfg.staticUrl;
        PAPERLESS_POST_CONSUME_SCRIPT = lib.mkIf (cfg.postConsumeScript != null) cfg.postConsumeScript;
        PAPERLESS_PRE_CONSUME_SCRIPT = lib.mkIf (cfg.preConsumeScript != null) cfg.preConsumeScript;
      };

      # Secret injection via environmentFile (SOPS)
      environmentFile = lib.mkIf (cfg.secretKeyFile != null) (
        lib.mkForce cfg.secretKeyFile
      );
    };

    # ── Systemd Hardening ──
    systemd.services.paperless-web.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [ cfg.dataDir cfg.consumptionDir ]
        ++ lib.optionals (cfg.mediaRoot != null) [ cfg.mediaRoot ]
        ++ lib.optionals (cfg.emptyTrashDir != null) [ cfg.emptyTrashDir ];
    };
  };
}
