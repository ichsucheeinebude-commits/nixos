# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-010"
# title: "PostgreSQL"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [core,postgresql,database]
# description: "PostgreSQL database service."
# path: "modules/00-core/09-postgresql.nix"
# provides: [my.core.postgresql]
# requires: []
# links:
#   adr: docs/adr/ADR-09-postgresql.md
#   guide: docs/guides/09-postgresql.md
#   module: modules/00-core/09-postgresql.nix
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
  options.my.core.postgresql = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable PostgreSQL."; };
    package = lib.mkOption { type = lib.types.package; default = null; };
  };

  config = lib.mkIf config.my.core.postgresql.enable {
    services.postgresql = {
      enable = true;
      package = lib.mkIf (config.my.core.postgresql.package != null) config.my.core.postgresql.package;
    };
    systemd.tmpfiles.rules = [ "d /run/postgresql 0755 postgres postgres -" ];
  };
}
