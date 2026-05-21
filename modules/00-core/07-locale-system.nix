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
