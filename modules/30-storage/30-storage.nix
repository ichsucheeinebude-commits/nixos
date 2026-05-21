# ---NIXMETA
# ---
# domain: 30
# id: "NIXH-30-STO-001"
# title: "Storage Configuration"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [storage,filesystems,tiering]
# description: "File system definitions and ABC tier mount points."
# path: "modules/30-storage/30-storage.nix"
# provides: [my.storage]
# requires: []
# links:
#   adr: docs/adr/ADR-30-storage.md
#   guide: docs/guides/30-storage.md
#   module: modules/30-storage/30-storage.nix
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

{ config, lib, ... }:
{
  options.my.storage = {
    tierA = lib.mkOption { type = lib.types.str; default = "/persist"; description = "Tier A: NVMe state."; };
    tierB = lib.mkOption { type = lib.types.str; default = "/mnt/cache"; description = "Tier B: SSD cache."; };
    tierC = lib.mkOption { type = lib.types.str; default = "/mnt/hdd_pool"; description = "Tier C: HDD archive."; };
    downloads = lib.mkOption { type = lib.types.str; default = "/mnt/cache/downloads"; };
    mediaLibrary = lib.mkOption { type = lib.types.str; default = "/mnt/cache/media"; };
    mediaArchive = lib.mkOption { type = lib.types.str; default = "/mnt/hdd_pool/media"; };
    stateDir = lib.mkOption { type = lib.types.str; default = "/var/lib"; };
    appData = lib.mkOption { type = lib.types.str; default = "/var/lib"; };
    privateData = lib.mkOption { type = lib.types.str; default = "/var/lib/private"; };
    devices = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
    fileSystems = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = {};
    };
  };

  config = {
    fileSystems = lib.mkMerge [ config.my.storage.fileSystems ];
  };
}
