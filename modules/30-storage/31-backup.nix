# ---NIXMETA
# ---
# domain: 30
# id: "NIXH-30-STO-002"
# title: "Backup"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [storage,backup,restic]
# description: "Restic backup configuration."
# path: "modules/30-storage/31-backup.nix"
# provides: [my.storage.backup]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/30-storage/31-backup.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
{
  options.my.storage.backup = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    repository = lib.mkOption { type = lib.types.str; default = "/mnt/archive/.restic-vault"; };
    remoteRepository = lib.mkOption { type = lib.types.str; default = ""; };
    paths = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "/etc/nixos" "/var/lib" ]; };
    pruneKeepDaily = lib.mkOption { type = lib.types.int; default = 7; };
    pruneKeepWeekly = lib.mkOption { type = lib.types.int; default = 4; };
    pruneKeepMonthly = lib.mkOption { type = lib.types.int; default = 6; };
    timerSchedule = lib.mkOption { type = lib.types.str; default = "02:00"; };
  };

  config = lib.mkIf config.my.storage.backup.enable {
    services.restic.backups."local" = {
      initialize = true;
      repository = config.my.storage.backup.repository;
      paths = config.my.storage.backup.paths;
      pruneOpts = [
        "--keep-daily ${toString config.my.storage.backup.pruneKeepDaily}"
        "--keep-weekly ${toString config.my.storage.backup.pruneKeepWeekly}"
        "--keep-monthly ${toString config.my.storage.backup.pruneKeepMonthly}"
      ];
      timerConfig = {
        OnCalendar = config.my.storage.backup.timerSchedule;
        Persistent = true;
      };
    };
  };
}
