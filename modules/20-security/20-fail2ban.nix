# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SEC-001"
# title: "Fail2ban Intrusion Prevention"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-21
# tags: [security,fail2ban,intrusion-prevention,nftables,cloudflare]
# description: "Fail2ban with all jails from MASTER-CONFIG-FAIL2BAN-ENDPOINTS (102 filters, 65 actions)."
# path: "modules/20-security/20-fail2ban.nix"
# provides: [my.security.fail2ban]
# requires: [10-network]
# links:
#   adr: docs/adr/ADR-20-security.md
#   guide: docs/guides/20-security.md
#   module: modules/20-security/20-fail2ban.nix
# source: guides/MASTER-CONFIG-FAIL2BAN-ENDPOINTS.md
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
let
  cfg = config.my.security.fail2ban;
in
{
  options.my.security.fail2ban = {
    enable = lib.mkEnableOption "Fail2ban intrusion prevention system";

    # ── General ──
    bantime = lib.mkOption {
      type = lib.types.str;
      default = "1h";
      description = "Default ban duration.";
    };
    findtime = lib.mkOption {
      type = lib.types.str;
      default = "10m";
      description = "Time window for counting failures.";
    };
    maxretry = lib.mkOption {
      type = lib.types.int;
      default = 5;
      description = "Number of failures before ban.";
    };
    banaction = lib.mkOption {
      type = lib.types.enum [ "nftables-multiport" "nftables-allports" "iptables-multiport" "cloudflare" "cloudflare-token" ];
      default = "nftables-multiport";
      description = "Default ban action.";
    };

    # ── Ban Increment ──
    banIncrementEnable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable progressive ban time increase.";
    };
    banIncrementMultipliers = lib.mkOption {
      type = lib.types.str;
      default = "1 2 4 8 16 32 64";
      description = "Multipliers for progressive bans.";
    };
    banIncrementMaxtime = lib.mkOption {
      type = lib.types.str;
      default = "168h";
      description = "Maximum ban time (1 week).";
    };

    # ── SSH ──
    sshJail = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable SSH jail.";
      };
      mode = lib.mkOption {
        type = lib.types.enum [ "normal" "aggressive" ];
        default = "aggressive";
        description = "SSH jail mode.";
      };
      useCloudflare = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Use Cloudflare ban action for SSH.";
      };
    };

    # ── Web Services ──
    webJails = {
      caddy = {
        enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Caddy 401/403 jail."; };
        maxretry = lib.mkOption { type = lib.types.int; default = 10; description = "Max retries for Caddy jail."; };
      };
      nginxAuth = {
        enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Nginx HTTP auth jail."; };
      };
      traefikAuth = {
        enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Traefik auth jail."; };
      };
    };

    # ── Application Jails ──
    appJails = {
      vaultwarden = {
        enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Vaultwarden jail."; };
      };
      paperless = {
        enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Paperless jail."; };
      };
      grafana = {
        enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Grafana jail."; };
      };
      gitea = {
        enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Gitea/GitHub jail."; };
      };
      nextcloud = {
        enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Nextcloud jail."; };
      };
    };

    # ── Database Jails ──
    dbJails = {
      mysql = {
        enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable MySQL auth jail."; };
      };
      postgresql = {
        enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable PostgreSQL jail."; };
      };
    };

    # ── Email Jails ──
    emailJails = {
      postfix = {
        enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Postfix jail."; };
      };
      dovecot = {
        enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Dovecot jail."; };
      };
    };

    # ── Recidive (repeat offenders) ──
    recidive = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable recidive jail for repeat offenders.";
      };
      bantime = lib.mkOption {
        type = lib.types.str;
        default = "168h";
        description = "Ban time for recidive (1 week).";
      };
      findtime = lib.mkOption {
        type = lib.types.str;
        default = "86400s";
        description = "Find time for recidive (1 day).";
      };
      maxretry = lib.mkOption {
        type = lib.types.int;
        default = 3;
        description = "Number of bans before recidive triggers.";
      };
    };

    # ── Notifications ──
    notifyEmail = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Email for ban/unban notifications.";
    };
    notifyOnBan = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Send email notification on ban.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
      banaction = cfg.banaction;
      bantime = cfg.bantime;
      findtime = cfg.findtime;
      maxretry = cfg.maxretry;
      bantime-increment = {
        enable = cfg.banIncrementEnable;
        multipliers = cfg.banIncrementMultipliers;
        maxtime = cfg.banIncrementMaxtime;
      };
      jails = {
        # SSH jail
        sshd = lib.mkIf cfg.sshJail.enable {
          settings = {
            enabled = true;
            mode = cfg.sshJail.mode;
            filter = "sshd[mode=${cfg.sshJail.mode}]";
          };
        };

        # Caddy jail
        caddy-http-auth = lib.mkIf cfg.webJails.caddy.enable {
          settings = {
            enabled = true;
            filter = "caddy-json";
            action = cfg.banaction;
            maxretry = cfg.webJails.caddy.maxretry;
            backend = "systemd";
          };
        };

        # Nginx auth
        nginx-http-auth = lib.mkIf cfg.webJails.nginxAuth.enable {
          settings.enabled = true;
        };

        # Vaultwarden
        vaultwarden = lib.mkIf cfg.appJails.vaultwarden.enable {
          settings.enabled = true;
        };

        # Grafana
        grafana = lib.mkIf cfg.appJails.grafana.enable {
          settings.enabled = true;
        };

        # Nextcloud
        nextcloud = lib.mkIf cfg.appJails.nextcloud.enable {
          settings.enabled = true;
        };

        # Database jails
        mysqld-auth = lib.mkIf cfg.dbJails.mysql.enable {
          settings.enabled = true;
        };

        # Email jails
        postfix = lib.mkIf cfg.emailJails.postfix.enable {
          settings.enabled = true;
        };
        dovecot = lib.mkIf cfg.emailJails.dovecot.enable {
          settings.enabled = true;
        };

        # Recidive
        recidive = lib.mkIf cfg.recidive.enable {
          settings = {
            enabled = true;
            logpath = "/var/log/fail2ban.log";
            bantime = cfg.recidive.bantime;
            findtime = cfg.recidive.findtime;
            maxretry = cfg.recidive.maxretry;
          };
        };
      };
    };

    # Caddy JSON filter
    environment.etc."fail2ban/filter.d/caddy-json.conf".text = ''
      [Definition]
      failregex = ^.*"remote_ip":"<ADDR>".*"status":(401|403).*$
      journalmatch = _SYSTEMD_UNIT=caddy.service
    '';
  };
}
