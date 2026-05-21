# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-005"
# title: "Boot Safeguards"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [core,boot,memtest,safeguards]
# description: "Boot configuration limits, memtest entry, and generation pruning."
# path: "modules/00-core/04-boot-safeguards.nix"
# provides: [my.core.boot]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/00-core/04-boot-safeguards.nix
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

{ config, lib, pkgs, ... }:
{
  options.my.core.boot = {
    configurationLimit = lib.mkOption { type = lib.types.int; default = 5; description = "Max boot generations."; };
    memtest = lib.mkOption { type = lib.types.bool; default = true; description = "Include memtest86+."; };
  };

  config = lib.mkIf config.my.core.principles.enable {
    boot.loader.systemd-boot.configurationLimit = config.my.core.boot.configurationLimit;
    boot.loader.systemd-boot.memtest86.enable = config.my.core.boot.memtest;
  };
}
