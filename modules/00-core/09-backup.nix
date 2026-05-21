# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-004"
# title: "Backup (Restic)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [backup,restic,cloud-sync,integrity-check]
# description: "Restic backup with automated integrity checks, max compression, and cloud sync via rclone."
# path: "modules/00-core/09-backup.nix"
# provides: [my.backup]
# requires: [00-core, 30-storage]
# links:
#   module: modules/00-core/09-backup.nix
# source: _meta/00-core/backup.nix (NIXH-00-COR-004)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
  cfg = config.my.backup;
  localRepo = "${cfg.repo}/.restic-vault";
in
{
  options.my.backup = {
    enable = lib.mkEnableOption "Restic backup with cloud sync";
    repo = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/backup";
      description = "Local backup repository path.";
    };
    passwordFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/secrets/restic-password";
      description = "Path to restic password file.";
    };
    maxSizeGB = lib.mkOption {
      type = lib.types.int;
      default = 15;
      description = "Maximum backup size in GB.";
    };
    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "/data/state" "/data/metadata" "/etc/nixos" ];
      description = "Paths to back up.";
    };
    remoteName = lib.mkOption {
      type = lib.types.str;
      default = "cloud-backup";
      description = "Rclone remote name for cloud sync.";
    };
    remotePath = lib.mkOption {
      type = lib.types.str;
      default = "nixhome-vault";
      description = "Rclone remote path.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.restic.backups.daily = {
      initialize = true;
      repository = localRepo;
      passwordFile = cfg.passwordFile;
      paths = cfg.paths;
      exclude = [ "**/.cache" "**/tmp" "**/node_modules" ];
      createWrapper = true;
      runCheck = true;
      checkOpts = [ "--with-cache" ];
      extraOptions = [ "--exclude-caches" "--compression=max" ];
      inhibitsSleep = true;
      timerConfig = {
        OnCalendar = "02:00";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
      pruneOpts = [ "--keep-daily 7" "--keep-weekly 4" "--keep-monthly 6" ];
    };

    systemd.services.restic-cloud-sync = {
      description = "Sync Restic Vault to Cloud";
      after = [ "restic-backups-daily.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.rclone}/bin/rclone sync ${localRepo} ${cfg.remoteName}:${cfg.remotePath} --bwlimit 5M";
      };
    };

    environment.systemPackages = with pkgs; [ restic rclone ];
  };
}
