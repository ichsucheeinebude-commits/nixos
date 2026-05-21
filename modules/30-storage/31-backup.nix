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

# ─── KB Nuggets ───
# ### 🏗️ 1. USER LAYER: DIE LAGERHAUS-LOGIK (KISS)
#
# Das System verwaltet deinen Speicher wie ein intelligentes, kaskadierendes Lagerhaus:
# - **Tier A (Hot/NVMe):** Der Hochgeschwindigkeits-Arbeitstisch. Blitzschnell durch ZFS-Optimierung.
# - **Tier B (Warm/SSD):** Das Zwischenlager. Hier landen neue Pakete und Überlauf-Daten.
# - **Tier C (Cold/HDD):** Der Friedhof. Hier ruhen Medien ohne unnötigen Energieverbrauch.
#
# ---
# ### A. Tier A (NVMe) — ZFS Härtung
#
# Wir optimieren ZFS für die spezifischen Charakteristika von NVMe-Flash-Speicher:
# | Option | Wert | Rationale |
# | :--- | :--- | :--- |
# | **`ashift`** | `12` | Korrekte Ausrichtung auf 4K-Sektoren (NAND-Alignment). |
# | **`compression`** | `zstd` | Maximale Durchsatz-Erhöhung bei geringer CPU-Last. |
# | **`xattr`** | `sa` | Metadaten-Speicherung im Inode (Speedup für Nix-Store). |
# | **`atime`** | `off` | Verhindert Schreibvorgänge bei jedem Lesezugriff (SSD-Schutz). |
# | **`autotrim`** | `on` | Echtzeit-Bereinigung freier Blöcke. |
#
# > [LIVE-ENRICHMENT]: Für den Mountpoint `/nix` setzen wir die `recordsize` auf **1M**. Dies reduziert den Metadaten-Overhead beim Laden großer Nix-Binärpakete massiv.
# ─── End KB Nuggets ───

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
