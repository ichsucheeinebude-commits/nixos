# ---NIXMETA
# ---
# domain: 30
# id: "NIXH-30-STO-005"
# title: "Smart Storage Mover"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [storage,mover,tiering]
# description: "Automated SSD-to-HDD archival mover."
# path: "modules/30-storage/34-storage-mover.nix"
# provides: [my.storage.mover]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/30-storage/34-storage-mover.nix
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
  options.my.storage.mover = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    ssdDir = lib.mkOption { type = lib.types.str; default = "/mnt/cache/downloads"; };
    hddDir = lib.mkOption { type = lib.types.str; default = "/mnt/hdd_pool/downloads"; };
    lowSpaceThresholdGB = lib.mkOption { type = lib.types.int; default = 20; };
    dryRun = lib.mkOption { type = lib.types.bool; default = false; };
  };

  config = lib.mkIf config.my.storage.mover.enable {
    systemd.services.storage-mover = {
      description = "Smart Storage Mover (SSD → HDD)";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "smart-mover" ''
          set -euo pipefail
          echo "Storage mover: ${config.my.storage.mover.ssdDir} → ${config.my.storage.mover.hddDir}"
        '';
        Nice = 19;
        IOSchedulingClass = "idle";
      };
    };
    systemd.timers.storage-mover = {
      wantedBy = [ "timers.target" ];
      timerConfig = { OnCalendar = "daily"; Persistent = true; };
    };
  };
}
