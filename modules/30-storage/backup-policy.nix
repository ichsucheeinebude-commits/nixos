# ---NIXMETA
# ---
# domain: 30
# id: "NIXH-30-STO-003"
# title: "Backup Policy Manager"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [storage,backup,policy,state-management]
# description: "Structured backup policy with nixarr state management. Defines what to backup and what to exclude."
# path: "modules/30-storage/backup-policy.nix"
# provides: [my.storage.backup-policy]
# requires: []
# links:
#   adr: docs/adr/ADR-30-storage.md
#   guide: docs/guides/30-storage.md
#   module: modules/30-storage/backup-policy.nix
# sources: [nix-media-server/nixarr]
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# nixarr pattern: State Management in /data/.state/nixarr/.
# Arr/Download-Daten sind wiederherstellbar → NICHT im Backup.
# Jellyfin Cache kann neu generiert werden → NICHT im Backup.
# ### Entscheidung
#
# Strukturierte Backup-Policy mit klaren Include/Exclude-Regeln.
# Media-Daten werden gebackupt (die eigentlichen Files).
# State/Cache/Downloads werden nicht gebackupt (wiederherstellbar).
# ─── End KB Nuggets ───

{ config, lib, ... }:

let
  cfg = config.my.storage.backup-policy;
  arrCfg = config.my.media.arr-stack;
  jellyfinCfg = config.my.media.jellyfin;
in
{
  options.my.storage.backup-policy = {
    enable = lib.mkEnableOption "Structured backup policy with nixarr state management";

    # ── Backup Destination ──
    destination = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/backup";
      description = "Backup destination directory.";
    };

    # ── Schedule ──
    schedule = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = "Backup schedule (daily, weekly, monthly).";
    };

    # ── What to Backup ──
    includePaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "/etc/nixos"                    # NixOS configuration
        "/var/lib"                      # Service data (excluding state dirs)
        "/home"                         # User home directories
        arrCfg.mediaDir                 # Media files (the actual content)
      ];
      description = "Paths to include in backup.";
    };

    # ── What to Exclude ──
    excludePaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        # ── Arr State (wiederherstellbar via Prowlarr/SABnzbd) ──
        "${arrCfg.stateDir}/radarr"
        "${arrCfg.stateDir}/sonarr"
        "${arrCfg.stateDir}/lidarr"
        "${arrCfg.stateDir}/prowlarr"
        "${arrCfg.stateDir}/readarr"
        "${arrCfg.stateDir}/sabnzbd"
        "${arrCfg.stateDir}/seerr"

        # ── Downloads (wiederherstellbar via SceneNZB) ──
        "${arrCfg.downloadDir}"
        "${arrCfg.downloadDir}/incomplete"

        # ── Jellyfin Cache (kann neu generiert werden) ──
        "${jellyfinCfg.stateDir}/cache"
        "${jellyfinCfg.stateDir}/transcodes"

        # ── System temp & cache ──
        "/tmp"
        "/var/tmp"
        "/var/cache"
      ];
      description = "Paths to exclude from backup.";
    };

    # ── Retention Policy ──
    retention = {
      daily = lib.mkOption {
        type = lib.types.int;
        default = 7;
        description = "Keep daily backups for N days.";
      };
      weekly = lib.mkOption {
        type = lib.types.int;
        default = 4;
        description = "Keep weekly backups for N weeks.";
      };
      monthly = lib.mkOption {
        type = lib.types.int;
        default = 12;
        description = "Keep monthly backups for N months.";
      };
    };

    # ── Encryption ──
    encryption = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable backup encryption.";
      };
      keyFile = lib.mkOption {
        type = lib.types.str;
        default = "/run/secrets/backup-key";
        description = "Path to encryption key file.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # ── Backup Exclusion File ──
    environment.etc."backup-exclude.conf".text = lib.concatStringsSep "\n" cfg.excludePaths;

    # ── Backup Script ──
    systemd.services.backup = {
      description = "Structured backup service";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.borgbackup}/bin/borg create "
          + "--exclude-caches "
          + "--exclude-from /etc/backup-exclude.conf "
          + "--compression zstd "
          + (lib.optionalString cfg.encryption.enable "--encryption=repokey ")
          + "${cfg.destination}::"
          + "\$(date +\\%Y-\\%m-\\%d_\\%H-\\%M-\\%S) "
          + lib.concatStringsSep " " cfg.includePaths;
        Nice = 19;
        IOSchedulingClass = "idle";
      };

      # ── Schedule ──
      startAt = lib.mkDefault "daily";

      # ── Retention Cleanup ──
      postStart = ''
        ${pkgs.borgbackup}/bin/borg prune \
          --keep-daily ${toString cfg.retention.daily} \
          --keep-weekly ${toString cfg.retention.weekly} \
          --keep-monthly ${toString cfg.retention.monthly} \
          ${cfg.destination}
      '';
    };

    # ── Backup State Directory ──
    systemd.tmpfiles.rules = [
      "d ${cfg.destination} 0700 root root -"
    ];
  };
}
