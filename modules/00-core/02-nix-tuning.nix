# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-003"
# title: "Nix Tuning"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [core,nix,gc,optimization]
# description: "Nix daemon tuning, GC settings, and build optimization."
# path: "modules/00-core/02-nix-tuning.nix"
# provides: [my.core.nix]
# requires: []
# links:
#   adr: docs/adr/ADR-00-core.md
#   guide: docs/guides/00-core.md
#   module: modules/00-core/02-nix-tuning.nix
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
  options.my.core.nix = {
    enable = lib.mkOption { type = lib.types.bool; default = true; description = "Apply nix tuning."; };
    gc.automatic = lib.mkOption { type = lib.types.bool; default = true; };
    gc.interval = lib.mkOption { type = lib.types.str; default = "weekly"; };
    gc.options = lib.mkOption { type = lib.types.str; default = "--delete-older-than 7d"; };
    optimise.automatic = lib.mkOption { type = lib.types.bool; default = true; };
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {
        auto-optimise-store = true;
        use-xdg-base-directories = true;
        experimental-features = [ "nix-command" "flakes" ];
        warn-dirty = false;
      };
    };
  };

  config = lib.mkIf (config.my.core.principles.enable && config.my.core.nix.enable) {
    nix = {
      gc = {
        automatic = config.my.core.nix.gc.automatic;
        dates = config.my.core.nix.gc.interval;
        options = config.my.core.nix.gc.options;
      };
      settings = config.my.core.nix.settings;
    };
    nix.optimise.automatic = config.my.core.nix.optimise.automatic;
  };
}
