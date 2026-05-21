# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-009"
# title: "Users & Groups"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [core,users,groups]
# description: "System user and group definitions (no shell aliases)."
# path: "modules/00-core/08-users-shell.nix"
# provides: [my.core.users]
# requires: []
# links:
#   adr: docs/adr/ADR-00-core.md
#   guide: docs/guides/00-core.md
#   module: modules/00-core/08-users-shell.nix
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
  options.my.core.users = {
    list = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption { type = lib.types.str; description = "Username."; };
          isNormalUser = lib.mkOption { type = lib.types.bool; default = true; };
          extraGroups = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
          openssh.authorizedKeys.keys = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "SSH public keys."; };
          shell = lib.mkOption { type = lib.types.package; default = null; };
        };
      });
      default = [];
      description = "List of users to create.";
    };
  };

  config = lib.mkIf (config.my.core.principles.enable && config.my.core.users.list != []) {
    users.users = lib.mkMerge (map (u: {
      ${u.name} = {
        inherit (u) isNormalUser;
        extraGroups = u.extraGroups;
        inherit (u) shell;
        openssh.authorizedKeys.keys = u.openssh.authorizedKeys.keys;
      };
    }) config.my.core.users.list);
  };
}
