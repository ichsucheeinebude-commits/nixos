{
  config,
  lib,
  pkgs,
  ...
}: let
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-00-COR-004";
    title = "Backup (Restic Expert)";
    description = "Secure Restic backup logic with automated integrity checks, high-compression and cloud sync.";
    layer = 00;
    nixpkgs.category = "services/backup";
    capabilities = ["backup/restic" "cloud/sync" "security/integrity-check"];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 2;
  };

  localRepo = "/mnt/archive/.restic-vault";
  maxSizeGB = 15;
in {
  options.my.meta.backup = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for backup module";
  };

  config = lib.mkIf config.my.services.backup.enable {
    services.restic.backups.daily = {
      initialize = true;
      repository = localRepo;
      passwordFile = "/etc/secrets/restic-password";

      paths = [
        "/data/state"
        "/data/metadata"
        "/etc/nixos"
        "/var/lib/pocket-id"
      ];

      # Nixpkgs 25.11 Optimierungen
      exclude = [
        "**/.cache"
        "**/tmp"
        "**/node_modules"
      ];

      createWrapper = true;
      runCheck = true;
      checkOpts = ["--with-cache"];

      # Maximale Kompression (Gamechanger für Cloud-Sync)
      extraOptions = [
        "--exclude-caches"
        "--compression=max"
      ];

      # SRE Safety: Verhindert Standby während Backup
      inhibitsSleep = true;

      backupPrepareCommand = ''
        DATA_SIZE=$(${pkgs.coreutils}/bin/du -sb /data/state /data/metadata /etc/nixos | ${pkgs.gawk}/bin/awk '{sum+=$1} END {print sum}')
        LIMIT=$(( ${toString maxSizeGB} * 1024 * 1024 * 1024 ))
        if [ "$DATA_SIZE" -gt "$LIMIT" ]; then
          echo "🚨 BACKUP ABGEBROCHEN: Limit überschritten!"
          exit 1
        fi
      '';

      timerConfig = {
        OnCalendar = "02:00";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];
    };

    systemd.services.restic-cloud-sync = {
      description = "Sync Restic Vault to Cloud";
      after = ["restic-backups-daily.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.rclone}/bin/rclone sync ${localRepo} cloud-backup:nixhome-vault --bwlimit 5M";
        ExecCondition = "${pkgs.systemd}/bin/systemctl is-active --quiet restic-backups-daily.service";
      };
    };

    environment.systemPackages = with pkgs; [restic rclone];
  };
}
/**
* ---
 * technical_integrity:
 *   checksum: sha256:59a711a8e1863926a4b150ad41e271cd8fb0df34a069fd5c5df6478d937b405d
 *   eof_marker: NIXHOME_VALID_EOF* ---
*/

