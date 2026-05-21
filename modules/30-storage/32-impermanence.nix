# ---NIXMETA
# ---
# domain: 30
# id: "NIXH-30-STO-003"
# title: "Impermanence"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [storage,impermanence,stateless]
# description: "Stateless root with /persist persistence."
# path: "modules/30-storage/32-impermanence.nix"
# provides: [my.storage.impermanence]
# requires: []
# links:
#   adr: docs/adr/ADR-32-impermanence.md
#   guide: docs/guides/32-impermanence.md
#   module: modules/30-storage/32-impermanence.nix
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
  options.my.storage.impermanence = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    persistDir = lib.mkOption { type = lib.types.str; default = "/persist"; };
    directories = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
    files = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
    ramfsSize = lib.mkOption { type = lib.types.str; default = "4G"; };
  };

  config = lib.mkIf config.my.storage.impermanence.enable {
    fileSystems."/" = lib.mkForce {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=${config.my.storage.impermanence.ramfsSize}" "mode=755" ];
    };
  };
}
