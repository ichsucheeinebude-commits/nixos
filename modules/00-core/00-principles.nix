# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-001"
# title: "Principles & Defaults"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [core,principles,bastelmodus]
# description: "Global toggle and experimental flag for the entire boilerplate."
# path: "modules/00-core/00-principles.nix"
# provides: [my.core.principles]
# requires: []
# links:
#   adr: docs/adr/ADR-00-principles.md
#   guide: docs/guides/00-principles.md
#   module: modules/00-core/00-principles.nix
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
  options.my.core.principles = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Master toggle for all core boilerplate options.";
    };
    bastelmodus = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Experimental playground flag. When false, strict policies are enforced.";
    };
  };
}
