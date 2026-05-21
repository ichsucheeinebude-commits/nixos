# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-007"
# title: "ZRAM Swap"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [core,zram,swap,memory]
# description: "Compressed RAM swap via zram."
# path: "modules/00-core/06-zram-swap.nix"
# provides: [my.core.zram]
# requires: []
# links:
#   adr: docs/adr/ADR-00-core.md
#   guide: docs/guides/00-core.md
#   module: modules/00-core/06-zram-swap.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### 🏗️ 1. USER LAYER: MODULARITÄT OHNE SCHMERZ (KISS)
#
# In herkömmlichen Nix-Systemen musst du jede neue Datei manuell in einer Liste eintragen. In unserem System ist das vorbei:
# - **Prinzip:** "Jede Datei ist ein Modul".
# - **Aktion:** Erstelle eine `.nix` Datei im Ordner `features/` – sie wird sofort vom System erkannt und geladen.
# - **Vorteil:** Du kannst dich auf das Konfigurieren konzentrieren, anstatt dich um Import-Strukturen zu kümmern.
#
# ---
# ### A. Die Engine: `flake-parts` & `den`
#
# Wir nutzen `flake-parts` als Basis und das `den` Framework zur Kontext-Steuerung.
# - **Auto-Import:** Integration von `import-tree`, um das gesamte Verzeichnis `./modules` rekursiv zu evaluieren.
# - **Deferred Modules:** Wir nutzen den Typ `deferredModule` aus Nixpkgs für Sub-Module, um Konflikte beim Mergen von Attributen (z.B. Firewall-Regeln) zu minimieren.
# ─── End KB Nuggets ───

{ config, lib, ... }:
{
  options.my.core.zram = {
    enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable zram swap."; };
    algorithm = lib.mkOption { type = lib.types.str; default = "zstd"; description = "Compression algorithm."; };
    memoryPercent = lib.mkOption { type = lib.types.int; default = 25; description = "Percentage of RAM for zram."; };
  };

  config = lib.mkIf (config.my.core.principles.enable && config.my.core.zram.enable) {
    zramSwap = {
      enable = true;
      algorithm = config.my.core.zram.algorithm;
      memoryPercent = config.my.core.zram.memoryPercent;
    };
  };
}
