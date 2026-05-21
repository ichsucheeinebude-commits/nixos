# ---NIXMETA
# ---
# domain: 40
# id: "NIXH-40-MON-047"
# title: "S3 Log Sync"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [monitoring,s3,rclone,offsite,backup]
# description: "Hourly off-site log sync to S3-compatible storage (e.g., Backblaze B2) via rclone. Uses SOPS-managed credentials."
# path: "modules/40-monitoring/47-s3-sync.nix"
# provides: [my.logging.s3Sync]
# requires: [00-core]
# links:
#   module: modules/40-monitoring/47-s3-sync.nix
# source: mynixos-v5/modules/logging/s3-sync.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

let
  cfg = config.my.logging.s3Sync;
in
{
  # ── S3 Log Sync ──
  # Hourly off-site log persistence to S3-compatible storage via rclone.

  options.my.logging.s3Sync = {
    enable = lib.mkEnableOption "Hourly off-site log sync to S3";
    bucket = lib.mkOption {
      type = lib.types.str;
      default = "logs";
      description = "S3 bucket name for log sync.";
    };
    endpoint = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "S3 endpoint URL (e.g., s3.us-west-004.backblazeb2.com).";
    };
    sourceDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/log/vector";
      description = "Local directory containing logs to sync.";
    };
    sopsEnvFile = lib.mkOption {
      type = lib.types.path;
      default = config.sops.templates."backblaze-restic.env".path or null;
      description = "SOPS-managed environment file with S3 credentials.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.log-s3-sync = {
      description = "S3 Log Sync";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        EnvironmentFile = cfg.sopsEnvFile;
        ExecStart = ''
          ${pkgs.rclone}/bin/rclone sync "${cfg.sourceDir}" ":s3:${cfg.bucket}/logs" \
            --s3-provider Other \
            --s3-endpoint "${cfg.endpoint}" \
            --s3-env-auth \
            --contimeout 60s \
            --timeout 300s \
            --retries 3 \
            --low-level-retries 10 \
            --stats 1m \
            --log-level ERROR
        '';
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        NoNewPrivileges = true;
        CapabilityBoundingSet = "";
        CacheDirectory = "rclone-s3-sync";
        CacheDirectoryMode = "0700";
      };
    };

    systemd.timers.log-s3-sync = {
      description = "Hourly S3 Log Sync Timer";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "hourly";
        RandomizedDelaySec = "5m";
        Persistent = true;
      };
    };
  };
}
