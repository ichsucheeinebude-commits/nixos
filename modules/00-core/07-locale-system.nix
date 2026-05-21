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
#   adr: docs/adr/ADR-07-locale-system.md
#   guide: docs/guides/07-locale-system.md
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
  # ── Locale Profiles (auto-detection) ──
  localeProfiles = {
    DE = { timeZone = "Europe/Berlin"; locale = "de_DE.UTF-8"; keyMap = "de-latin1"; xkbLayout = "de"; };
    AT = { timeZone = "Europe/Vienna";  locale = "de_AT.UTF-8"; keyMap = "de-latin1"; xkbLayout = "de"; };
    CH = { timeZone = "Europe/Zurich";  locale = "de_CH.UTF-8"; keyMap = "de-latin1"; xkbLayout = "de"; };
    US = { timeZone = "America/New_York"; locale = "en_US.UTF-8"; keyMap = "us"; xkbLayout = "us"; };
  };

  options.my.core.locale = {
    timezone = lib.mkOption { type = lib.types.str; default = ""; description = "Timezone (e.g. Europe/Berlin)."; };
    default = lib.mkOption { type = lib.types.str; default = ""; description = "Default locale (e.g. de_DE.UTF-8)."; };
    keymap = lib.mkOption { type = lib.types.str; default = "us"; description = "Console keymap."; };
    extraLocales = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "en_US.UTF-8/UTF-8" ]; };
    autoDetect.enable = lib.mkEnableOption "Auto-detect locale via IP geolocation (defaults to DE fallback)";
    autoDetect.country = lib.mkOption {
      type = lib.types.str;
      default = "DE";
      description = "Country code (ISO 3166-1 alpha-2) for locale profile selection.";
    };
  };

  selectedProfile = localeProfiles.${config.my.core.locale.autoDetect.country} or localeProfiles.DE;

  # ── Auto-detected values (can be overridden by explicit settings) ──
  autoTimeZone = lib.mkIf (config.my.core.locale.timezone == "" && config.my.core.locale.autoDetect.enable)
    selectedProfile.timeZone;
  autoLocale = lib.mkIf (config.my.core.locale.default == "" && config.my.core.locale.autoDetect.enable)
    selectedProfile.locale;
  autoKeyMap = lib.mkIf (config.my.core.locale.keymap == "us" && config.my.core.locale.autoDetect.enable)
    selectedProfile.keyMap;

  config = lib.mkIf config.my.core.principles.enable {
    # ── Timezone ──
    time.timeZone = lib.mkMerge [
      (lib.mkIf (config.my.core.locale.timezone != "") config.my.core.locale.timezone)
      autoTimeZone
    ];

    # ── Locale ──
    i18n.defaultLocale = lib.mkMerge [
      (lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default)
      autoLocale
    ];
    i18n.extraLocaleSettings = {
      LC_ADDRESS = lib.mkMerge [
        (lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default)
        (lib.mkIf (config.my.core.locale.autoDetect.enable) selectedProfile.locale)
      ];
      LC_IDENTIFICATION = lib.mkMerge [
        (lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default)
        (lib.mkIf (config.my.core.locale.autoDetect.enable) selectedProfile.locale)
      ];
      LC_MEASUREMENT = lib.mkMerge [
        (lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default)
        (lib.mkIf (config.my.core.locale.autoDetect.enable) selectedProfile.locale)
      ];
      LC_MONETARY = lib.mkMerge [
        (lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default)
        (lib.mkIf (config.my.core.locale.autoDetect.enable) selectedProfile.locale)
      ];
      LC_NAME = lib.mkMerge [
        (lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default)
        (lib.mkIf (config.my.core.locale.autoDetect.enable) selectedProfile.locale)
      ];
      LC_NUMERIC = lib.mkMerge [
        (lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default)
        (lib.mkIf (config.my.core.locale.autoDetect.enable) selectedProfile.locale)
      ];
      LC_PAPER = lib.mkMerge [
        (lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default)
        (lib.mkIf (config.my.core.locale.autoDetect.enable) selectedProfile.locale)
      ];
      LC_TELEPHONE = lib.mkMerge [
        (lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default)
        (lib.mkIf (config.my.core.locale.autoDetect.enable) selectedProfile.locale)
      ];
      LC_TIME = lib.mkMerge [
        (lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default)
        (lib.mkIf (config.my.core.locale.autoDetect.enable) selectedProfile.locale)
      ];
    };

    # ── Keymap ──
    console.keyMap = lib.mkMerge [
      config.my.core.locale.keymap
      (lib.mkIf (config.my.core.locale.autoDetect.enable) autoKeyMap)
    ];
    services.xserver.xkb.layout = lib.mkMerge [
      config.my.core.locale.keymap
      (lib.mkIf (config.my.core.locale.autoDetect.enable) selectedProfile.xkbLayout)
    ];

    # ── Supported Locales ──
    i18n.supportedLocales = lib.mkIf (config.my.core.locale.default != "" || config.my.core.locale.autoDetect.enable)
      ([ "${if config.my.core.locale.default != "" then config.my.core.locale.default else selectedProfile.locale}/UTF-8" ] ++ config.my.core.locale.extraLocales);

    # ── Auto-Detect Service (one-shot geolocation) ──
    systemd.services.auto-locale-detect = lib.mkIf config.my.core.locale.autoDetect.enable {
      description = "Auto-Locale: Detect Country via IP Geolocation";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        set -euo pipefail
        CACHE_DIR="/var/lib/auto-locale"
        mkdir -p "$CACHE_DIR"
        COUNTRY=$(curl -sf --max-time 5 "http://ip-api.com/json/?fields=countryCode" | jq -r '.countryCode' 2>/dev/null || echo "")
        if [ -n "$COUNTRY" ]; then
          echo "$COUNTRY" > "$CACHE_DIR/country"
          logger -t auto-locale "Detected country: $COUNTRY"
        else
          logger -t auto-locale "Geolocation failed, using fallback: ${config.my.core.locale.autoDetect.country}"
        fi
      '';
    };
  };
}
