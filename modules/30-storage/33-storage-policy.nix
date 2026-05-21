# ---NIXMETA
# ---
# domain: 30
# id: "NIXH-30-STO-004"
# title: "Storage Policy"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [storage,policy,assertions]
# description: "Storage tiering policy assertions."
# path: "modules/30-storage/33-storage-policy.nix"
# provides: [my.storage.policy]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/30-storage/33-storage-policy.nix
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
  options.my.storage.policy = {
    enable = lib.mkOption { type = lib.types.bool; default = true; };
  };

  config = lib.mkIf config.my.storage.policy.enable {
    assertions = [
      {
        assertion = config.my.storage.tierA == "/persist";
        message = "ABC Tiering Error: Tier A MUST be /persist.";
      }
    ];
  };
}
