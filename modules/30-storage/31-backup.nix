# ---NIXMETA
# ---
# domain: 30
# id: "NIXH-30-BKP-001"
# title: "Restic Backup"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [backup, restic]
# description: "Restic Backup module."
# path: "modules/30-storage/31-backup.nix"
# provides: [my.storage.backup]
# requires: [30-storage/30-storage]
# links:
#   adr: docs/adr/ADR-30-backup.md
#   guide: docs/guides/30-backup.md
#   module: modules/30-storage/31-backup.nix
# ---
# ---ENDNIXMETA

# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-000-COR-BCK-001",
#   "title": "Hardened Restic Backups",
#   "layer": 0,
#   "category": "core/security",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 3,
#   "tags": ["backup", "restic", "cloud-sync", "hardened"],
#   "description": "Hardened Restic backup configuration with dual local/cloud strategy and weekly integrity audits."
# }
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
let
  
  localRepo = "/mnt/archive/.restic-vault";
  maxSizeGB = 20;
in
{
  options.my.meta.backup = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  options.my.services.backup = {
    enable = lib.mkEnableOption "Hardened Restic Backups";
  };

  config = lib.mkIf config.my.services.backup.enable {
    # 🔐 SOPS: Rclone Config Protection
    sops.secrets.rclone_config = {
      owner = "root";
      # Die Rclone-Config enthält Cloud-Credentials und wird hardware-gebunden geschützt.
    };

    # 🔐 RESTIC BACKUP (anchor: restic-backup)
    services.restic.backups.daily = {
      initialize = true;
      repository = localRepo;
      passwordFile = config.sops.secrets.restic_password.path;

      paths = [
        config.my.configs.paths.appData
        config.my.configs.paths.tierA
        "/etc/nixos"
        "/var/lib/pocket-id"
        "/persist"
      ];

      exclude = [ "**/.cache" "**/tmp" "**/node_modules" "*.log" ];
      createWrapper = true;
      runCheck = true;
      checkOpts = ["--with-cache"];
      extraOptions = [ "--exclude-caches" "--compression=max" ];
      inhibitsSleep = true;

      # 🛡️ PRE-FLIGHT CHECK (Hardened)
      backupPrepareCommand = ''
        DATA_SIZE=$(${pkgs.coreutils}/bin/du -sb ${config.my.configs.paths.appData} /etc/nixos /persist /var/lib/pocket-id | ${pkgs.gawk}/bin/awk '{sum+=$1} END {print sum}')
        LIMIT=$(( ${toString maxSizeGB} * 1024 * 1024 * 1024 ))
        if [ "$DATA_SIZE" -gt "$LIMIT" ]; then
          echo "🚨 BACKUP ABGEBROCHEN: Datenmenge ($DATA_SIZE) > Limit ($LIMIT)!"
          exit 1
        fi
      '';

      # ☁️ CLOUD SYNC (v7.1 Hardened: direct restic-remote job instead of rclone sync)
      # backupCleanupCommand was removed to avoid double backups and reduce overhead.
      # Off-site persistence is now handled directly by services.restic.backups.remote.

      timerConfig = {
        OnCalendar = "02:00";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };

      pruneOpts = [ "--keep-daily 7" "--keep-weekly 4" "--keep-monthly 6" ];
    };

    # 🕵️ WEEKLY INTEGRITY AUDIT (anchor: backup-audit)
    # Perform a deeper check of 10% of the data once a week.
    systemd.services.restic-backup-audit = {
      description = "Deep Audit of Restic Backup Integrity";
      startAt = "weekly";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.restic}/bin/restic -r ${localRepo} check --read-data-subset=10% --password-file ${config.sops.secrets.restic_password.path}";
        # Hardening
        CPUWeight = 50;
        IOWeight = 50;
      };
    };

    services.restic.backups.remote = {
      initialize = true;
      repository = "s3:s3.eu-central-003.backblazeb2.com/nixhome-backup";
      passwordFile = config.sops.secrets.restic_password.path;
      environmentFile = config.sops.templates."backblaze-restic.env".path;

      paths = [ "/var/lib" "/etc" "/persist" ];
      exclude = [ "**/.cache" "**/tmp" ];
      pruneOpts = [ "--keep-daily 7" "--keep-weekly 4" "--keep-monthly 6" ];
      timerConfig = { OnCalendar = "03:00"; Persistent = true; };
      extraOptions = [ "--compression=max" ];
    };

    environment.systemPackages = with pkgs; [ restic rclone ];
  };
}
