# ---NIXMETA
# ---
# domain: 40
# id: "NIXH-40-MON-046"
# title: "Vector RAM-Buffered Logging"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-22
# tags: [monitoring,vector,logging,ram-buffer,ntfy,alerting]
# description: "RAM-buffered Vector logging pipeline. Collects journald, host metrics, and /var/log. Masks sensitive data, routes ERROR-level alerts to ntfy. Logs written to SSD with rotation."
# path: "modules/40-monitoring/46-vector-ram.nix"
# provides: [my.logging.vector]
# requires: [00-core]
# links:
#   module: modules/40-monitoring/46-vector-ram.nix
# source: mynixos-v5/modules/logging/vector-ram.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

let
  cfg = config.my.logging.vector;
  stateDir = config.my.core.paths.stateDir or "/data/state";
  logDir = "/var/log/vector";
  maxTotalSizeMB = 2048;
in
{
  # ── Vector RAM-Buffered Logging ──
  # RAM-buffered to SSD with ntfy emergency alerts.
  # Sources: journald, host_metrics, /var/log/*.log
  # Transforms: sensitive data masking, error filtering.

  options.my.logging.vector = {
    enable = lib.mkEnableOption "Vector RAM-buffered logging with ntfy alerts";
    retentionDays = lib.mkOption {
      type = lib.types.int;
      default = 30;
      description = "Days to retain rotated log files.";
    };
    maxFileSizeMB = lib.mkOption {
      type = lib.types.int;
      default = 256;
      description = "Max size per log file chunk in MB.";
    };
    ntfyTopic = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Ntfy topic for emergency ERROR-level alerts. Null to disable.";
    };
    ntfyUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://ntfy.sh";
      description = "Base URL for the ntfy server.";
    };
  };

  config = lib.mkIf cfg.enable {
    # ── Journald: Volatile (RAM only) ──
    services.journald.extraConfig = "Storage=volatile";

    # ── Vector Service ──
    services.vector = {
      enable = true;
      config = {
        sources.journald = {
          type = "journald";
          current_boot_only = false;
        };

        sources.host_metrics = {
          type = "host_metrics";
          scrape_interval_secs = 15;
        };

        sources.var_log = {
          type = "file";
          include = [ "/var/log/*.log" ];
        };

        # Sensitive data masking
        transforms.mask_sensitive = {
          type = "remap";
          inputs = [ "journald" "var_log" "host_metrics" ];
          source = ''
            .message = replace(.message, r'/mnt/(media|hdd_pool|tierC)/[^\s]+', "[MEDIA_PATH]")
            .message = replace(.message, r'Bearer\s+[A-Za-z0-9\-_\.]{20,}', "Bearer [REDACTED]")
            .message = replace(.message, r'[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}', "[UUID_REDACTED]")
            .message = replace(.message, r'(?i)("?api[_-]?key"?"?|"token"?"?|"secret"?"?|"password"?"?)\s*[=:]\s*["'']?\S+["'']?', "[CREDENTIAL_REDACTED]")
          '';
        };

        # Error filter for ntfy alerts
        transforms.error_filter = {
          type = "filter";
          inputs = [ "mask_sensitive" ];
          condition = ''includes(["err", "crit", "alert", "emerg"], .priority) || .level == "error" || .level == "critical" '';
        };

        sinks = {
          # SSD sink with RAM buffering
          file = {
            type = "file";
            inputs = [ "mask_sensitive" ];
            path = "${logDir}/journal-%Y-%m-%d.log";
            encoding.codec = "ndjson";
            compression = "gzip";
            batch.max_bytes = 128 * 1024 * 1024;
            batch.timeout_secs = 300;
            buffer = {
              type = "memory";
              max_size = 256 * 1024 * 1024;
              when_full = "block";
            };
            healthcheck = true;
          };
        } // (lib.optionalAttrs (cfg.ntfyTopic != null) {
          ntfy = {
            type = "http";
            inputs = [ "error_filter" ];
            uri = "${cfg.ntfyUrl}/${cfg.ntfyTopic}";
            method = "post";
            encoding.codec = "text";
            batch.max_events = 1;
          };
        });
      };
    };

    # ── Log Rotation ──
    systemd.services.rotate-vector-logs = {
      description = "Rotate and delete old Vector logs";
      serviceConfig = {
        Type = "oneshot";
        Nice = 19;
        IOSchedulingClass = "idle";
        User = "root";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ logDir ];
        CapabilityBoundingSet = "";
        PrivateTmp = true;
        ExecStart = pkgs.writeShellScript "rotate-vector-logs" ''
          set -euo pipefail
          # Age-based deletion
          ${pkgs.findutils}/bin/find "${logDir}" -name "*.log.gz" -type f -mtime +${toString cfg.retentionDays} -delete

          # Size-based deletion
          if [ -d "${logDir}" ]; then
            CURRENT_SIZE=$(${pkgs.coreutils}/bin/du -sm "${logDir}" | ${pkgs.coreutils}/bin/cut -f1)
            if [ "$CURRENT_SIZE" -gt ${toString maxTotalSizeMB} ]; then
              echo "Log directory ($CURRENT_SIZE MB) exceeds limit (${toString maxTotalSizeMB} MB). Cleaning..."
              ${pkgs.findutils}/bin/find "${logDir}" -name "*.log.gz" -type f -printf "%T+ %p\n" | sort | awk '{print $2}' | while read -r file; do
                rm -f -- "$file"
                CURRENT_SIZE=$(${pkgs.coreutils}/bin/du -sm "${logDir}" | ${pkgs.coreutils}/bin/cut -f1)
                [ "$CURRENT_SIZE" -le ${toString maxTotalSizeMB} ] && break
              done
            fi
          fi
        '';
      };
    };

    systemd.timers.rotate-vector-logs = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
    };

    systemd.tmpfiles.rules = [ "d ${logDir} 0750 root root - -" ];
  };
}
