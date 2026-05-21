# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-002"
# title: "Vaultwarden"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [apps,vaultwarden,password-manager,security]
# description: "Vaultwarden password manager with full option interface from MASTER-CONFIG."
# path: "modules/60-apps/62-vaultwarden.nix"
# provides: [my.apps.vaultwarden]
# requires: [10-network, 30-storage]
# links:
#   adr: docs/adr/ADR-60-apps.md
#   guide: docs/guides/60-apps.md
#   module: modules/60-apps/62-vaultwarden.nix
# source: guides/MASTER-CONFIG-VAULTWARDEN.md
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
let
  cfg = config.my.apps.vaultwarden;
in
{
  options.my.apps.vaultwarden = {
    enable = lib.mkEnableOption "Vaultwarden password manager";

    # ── Network ──
    domain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Public domain (e.g., https://vault.m7c5.de). Required for HTTPS features.";
    };
    listenIp = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "IP address to listen on.";
    };
    listenPort = lib.mkOption {
      type = lib.types.port;
      default = 8282;
      description = "Port for Vaultwarden web interface.";
    };
    websocketPort = lib.mkOption {
      type = lib.types.port;
      default = 3012;
      description = "Port for WebSocket notifications.";
    };

    # ── Database ──
    databaseBackend = lib.mkOption {
      type = lib.types.enum [ "sqlite" "postgresql" "mysql" ];
      default = "sqlite";
      description = "Database backend to use.";
    };
    databaseUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Database URL for PostgreSQL/MySQL. Auto-generated for SQLite.";
    };

    # ── Admin ──
    adminTokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to file containing admin token (via SOPS).";
    };

    # ── Security ──
    signupsAllowed = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether new user signups are allowed.";
    };
    signupsVerify = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether new users must verify email before login.";
    };
    signupsDomainsWhitelist = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of email domains allowed for signup.";
    };
    invitationsAllowed = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether admin invitations are required for signup.";
    };
    emergencyAccessAllowed = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether emergency access is allowed.";
    };
    passwordHintAllowed = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether password hints are allowed.";
    };
    ipHeader = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "X-Real-IP";
      description = "Header containing the real client IP (for reverse proxy setups).";
    };
    rocketLimits = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "512 KiB" ];
      description = "Rocket upload size limits.";
    };

    # ── Data ──
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/vaultwarden";
      description = "Data directory for SQLite database and attachments.";
    };

    # ── SMTP (email notifications) ──
    smtpEnabled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether SMTP is enabled for email notifications.";
    };
    smtpHost = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "SMTP server hostname.";
    };
    smtpPort = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
      description = "SMTP server port.";
    };
    smtpSsl = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use SSL for SMTP.";
    };
    smtpFrom = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Sender email address.";
    };
    smtpUsername = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "SMTP username.";
    };
    smtpPasswordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to file containing SMTP password (via SOPS).";
    };

    # ── Yubico OTP ──
    yubicoClientId = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Yubico OTP client ID.";
    };
    yubicoSecretKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to file containing Yubico secret key (via SOPS).";
    };

    # ── Duo 2FA ──
    duoIkey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Duo integration key.";
    };
    duoSkeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to file containing Duo secret key (via SOPS).";
    };
    duoHost = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Duo API hostname.";
    };

    # ── Push notifications (self-hosted relay) ──
    pushRelayUri = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Push relay server URI.";
    };
    pushId = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Push server ID.";
    };
    pushKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to file containing push server key (via SOPS).";
    };

    # ── OIDC SSO ──
    oidcEnabled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether OIDC SSO is enabled.";
    };
    oidcIssuer = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "OIDC issuer URL (e.g., PocketID).";
    };
    oidcClientId = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "OIDC client ID.";
    };
    oidcClientSecretFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to file containing OIDC client secret (via SOPS).";
    };
    oidcRedirectUri = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "OIDC redirect URI.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      config = {
        DOMAIN = lib.mkIf (cfg.domain != null) cfg.domain;
        ROCKET_ADDRESS = cfg.listenIp;
        ROCKET_PORT = toString cfg.listenPort;
        WEBSOCKET_ADDRESS = cfg.listenIp;
        WEBSOCKET_PORT = toString cfg.websocketPort;
        DATABASE_URL = lib.mkIf (cfg.databaseBackend != "sqlite") cfg.databaseUrl;
        ADMIN_TOKEN = lib.mkIf (cfg.adminTokenFile != null) { _file = cfg.adminTokenFile; };
        SIGNUPS_ALLOWED = cfg.signupsAllowed;
        SIGNUPS_VERIFY = cfg.signupsVerify;
        SIGNUPS_DOMAINS_WHITELIST = lib.mkIf (cfg.signupsDomainsWhitelist != [])
          (lib.concatStringsSep "," cfg.signupsDomainsWhitelist);
        INVITATIONS_ALLOWED = cfg.invitationsAllowed;
        EMERGENCY_ACCESS_ALLOWED = cfg.emergencyAccessAllowed;
        PASSWORD_HINT_ALLOWED = cfg.passwordHintAllowed;
        IP_HEADER = lib.mkIf (cfg.ipHeader != null) cfg.ipHeader;
        ROCKET_LIMITS = lib.concatStringsSep "," cfg.rocketLimits;
        SMTP_ENABLED = cfg.smtpEnabled;
        SMTP_HOST = lib.mkIf (cfg.smtpHost != null) cfg.smtpHost;
        SMTP_PORT = lib.mkIf (cfg.smtpPort != null) (toString cfg.smtpPort);
        SMTP_SSL = cfg.smtpSsl;
        SMTP_FROM = lib.mkIf (cfg.smtpFrom != null) cfg.smtpFrom;
        SMTP_USERNAME = lib.mkIf (cfg.smtpUsername != null) cfg.smtpUsername;
        SMTP_PASSWORD = lib.mkIf (cfg.smtpPasswordFile != null) { _file = cfg.smtpPasswordFile; };
        YUBICO_CLIENT_ID = lib.mkIf (cfg.yubicoClientId != null) cfg.yubicoClientId;
        YUBICO_SECRET_KEY = lib.mkIf (cfg.yubicoSecretKeyFile != null) { _file = cfg.yubicoSecretKeyFile; };
        DUO_IKEY = lib.mkIf (cfg.duoIkey != null) cfg.duoIkey;
        DUO_SKEY = lib.mkIf (cfg.duoSkeyFile != null) { _file = cfg.duoSkeyFile; };
        DUO_HOST = lib.mkIf (cfg.duoHost != null) cfg.duoHost;
        PUSH_ENABLED = lib.mkIf (cfg.pushRelayUri != null) true;
        PUSH_RELAY_URI = lib.mkIf (cfg.pushRelayUri != null) cfg.pushRelayUri;
        PUSH_INSTALLATION_ID = lib.mkIf (cfg.pushId != null) cfg.pushId;
        PUSH_INSTALLATION_KEY = lib.mkIf (cfg.pushKeyFile != null) { _file = cfg.pushKeyFile; };
        SSO_ENABLED = cfg.oidcEnabled;
        SSO_AUTHORITY = lib.mkIf cfg.oidcEnabled cfg.oidcIssuer;
        SSO_CLIENT_ID = lib.mkIf cfg.oidcEnabled cfg.oidcClientId;
        SSO_CLIENT_SECRET = lib.mkIf cfg.oidcEnabled { _file = cfg.oidcClientSecretFile; };
        SSO_REDIRECT_URL = lib.mkIf cfg.oidcEnabled cfg.oidcRedirectUri;
      };
      dbBackend = cfg.databaseBackend;
    };

    # ── Systemd Hardening ──
    systemd.services.vaultwarden.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [ cfg.dataDir ];
    };
  };
}
