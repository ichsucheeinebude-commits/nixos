# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-008"
# title: "Locale & System"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [core,locale,timezone,keymap]
# description: "System locale, timezone, and keymap configuration."
# path: "modules/00-core/07-locale-system.nix"
# provides: [my.core.locale]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/00-core/07-locale-system.nix
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
  options.my.core.locale = {
    timezone = lib.mkOption { type = lib.types.str; default = ""; description = "Timezone (e.g. Europe/Berlin)."; };
    default = lib.mkOption { type = lib.types.str; default = ""; description = "Default locale (e.g. de_DE.UTF-8)."; };
    keymap = lib.mkOption { type = lib.types.str; default = "us"; description = "Console keymap."; };
    extraLocales = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "en_US.UTF-8/UTF-8" ]; };
  };

  config = lib.mkIf config.my.core.principles.enable {
    time.timeZone = lib.mkIf (config.my.core.locale.timezone != "") config.my.core.locale.timezone;
    i18n.defaultLocale = lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default;
    i18n.extraLocaleSettings = {
      LC_ADDRESS = lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default;
      LC_IDENTIFICATION = lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default;
      LC_MEASUREMENT = lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default;
      LC_MONETARY = lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default;
      LC_NAME = lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default;
      LC_NUMERIC = lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default;
      LC_PAPER = lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default;
      LC_TELEPHONE = lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default;
      LC_TIME = lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default;
    };
    console.keyMap = config.my.core.locale.keymap;
    i18n.supportedLocales = lib.mkIf (config.my.core.locale.default != "")
      ([ "${config.my.core.locale.default}/UTF-8" ] ++ config.my.core.locale.extraLocales);
  };
}
