# ---NIXMETA
# ---
# domain: 30
# id: "NIXH-30-STO-005"
# title: "Storage Mover (ABC Tiering)"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-21
# tags: [storage,abc-tiering,mergerfs,tiering,automation]
# description: "ABC storage tiering engine — automated data movement between NVMe/SSD/HDD tiers."
# path: "modules/30-storage/34-storage-mover.nix"
# provides: [my.storage.mover]
# requires: [30-storage]
# links:
#   adr: docs/adr/ADR-34-storage-mover.md
#   guide: docs/guides/34-storage-mover.md
#   module: modules/30-storage/34-storage-mover.nix
# source: services/abc-storage-mover.md
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
let
  cfg = config.my.storage.mover;
in
{
  options.my.storage.mover = {
    enable = lib.mkEnableOption "ABC storage tiering engine for automated data movement";

    # ── Tier Definitions ──
    tierAPath = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/tier-a";
      description = "Tier A path (NVMe — hot data, OS, appdata).";
    };
    tierBPath = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/tier-b";
      description = "Tier B path (SSD — warm data, download cache).";
    };
    tierCPath = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/tier-c";
      description = "Tier C path (HDD — cold data, media archive).";
    };

    # ── Tiering Policy ──
    hotThresholdDays = lib.mkOption {
      type = lib.types.int;
      default = 7;
      description = "Days of inactivity before data is considered 'warm' (Tier A → B).";
    };
    warmThresholdDays = lib.mkOption {
      type = lib.types.int;
      default = 30;
      description = "Days of inactivity before data is considered 'cold' (Tier B → C).";
    };
    minFreeSpaceA = lib.mkOption {
      type = lib.types.str;
      default = "20%";
      description = "Minimum free space on Tier A before emergency demotion triggers.";
    };
    emergencyDemotion = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically demote oldest files when Tier A is below minFreeSpaceA.";
    };

    # ── MergerFS ──
    mergerfsEnabled = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable MergerFS to present a unified view of all tiers.";
    };
    mergerfsMountPoint = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/storage";
      description = "Unified MergerFS mount point.";
    };
    mergerfsPolicy = lib.mkOption {
      type = lib.types.str;
      default = "epmfs";
      description = "MergerFS create policy (epmfs = existing path, most free space).";
    };
    mergerfsCategory = lib.mkOption {
      type = lib.types.str;
      default = "defaults";
      description = "MergerFS category for mount options.";
    };

    # ── Schedule ──
    schedule = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = "Tiering schedule: daily, weekly, monthly, or systemd timer string.";
    };
    ioniceClass = lib.mkOption {
      type = lib.types.int;
      default = 3;
      description = "ionice class for tiering operations (3 = idle).";
    };
    niceLevel = lib.mkOption {
      type = lib.types.int;
      default = 19;
      description = "nice level for tiering operations.";
    };

    # ── Exclusions ──
    excludePatterns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "*.lock" "*.tmp" ".git/" ];
      description = "File patterns to exclude from tiering.";
    };
    excludePaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Absolute paths to exclude from tiering.";
    };

    # ── Notifications ──
    notifyOnCompletion = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Send notification on tiering completion.";
    };
    notifyOnEmergencyDemotion = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Send notification when emergency demotion triggers.";
    };
  };

  config = lib.mkIf cfg.enable {
    # MergerFS configuration
    services.mergerfs = lib.mkIf cfg.mergerfsEnabled {
      enable = true;
      mountPoint = cfg.mergerfsMountPoint;
      options = [
        "defaults"
        "allow_other"
        "direct_io"
        "use_ino"
        "category.create=${cfg.mergerfsPolicy}"
        "cache.files=auto-full"
        "func.getattr=newest"
      ];
      srcmnts = "${cfg.tierAPath}:${cfg.tierBPath}:${cfg.tierCPath}";
    };

    # Tiering systemd service
    systemd.services.abc-storage-mover = {
      description = "ABC Storage Tiering — automated data movement between tiers";
      script = ''
        #!/usr/bin/env bash
        set -euo pipefail

        # Hot → Warm (Tier A → B)
        find "${cfg.tierAPath}" -type f -mtime +${toString cfg.hotThresholdDays} \
          ${lib.concatMapStringsSep " " (p: "! -name '${p}'") cfg.excludePatterns} \
          -exec mv -t "${cfg.tierBPath}" {} + 2>/dev/null || true

        # Warm → Cold (Tier B → C)
        find "${cfg.tierBPath}" -type f -mtime +${toString cfg.warmThresholdDays} \
          ${lib.concatMapStringsSep " " (p: "! -name '${p}'") cfg.excludePatterns} \
          -exec mv -t "${cfg.tierCPath}" {} + 2>/dev/null || true

        # Emergency demotion if Tier A is below threshold
        if [ "${cfg.emergencyDemotion}" = "true" ]; then
          usage=$(df "${cfg.tierAPath}" | tail -1 | awk '{print $5}' | tr -d '%')
          threshold=$(echo "${cfg.minFreeSpaceA}" | tr -d '%')
          if [ "$usage" -gt "$((100 - threshold))" ]; then
            find "${cfg.tierAPath}" -type f -printf '%T+ %p\n' | sort | head -100 | awk '{print $2}' | \
              xargs -I{} mv {} "${cfg.tierBPath}" 2>/dev/null || true
          fi
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        Nice = toString cfg.niceLevel;
        IOSchedulingClass = toString cfg.ioniceClass;
        ProtectSystem = "strict";
        ProtectHome = false;
        ReadWritePaths = [ cfg.tierAPath cfg.tierBPath cfg.tierCPath ];
      };
    };

    # Timer for tiering
    systemd.timers.abc-storage-mover = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
    };
  };
}
