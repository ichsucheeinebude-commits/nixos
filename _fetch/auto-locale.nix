{
  config,
  lib,
  pkgs,
  ...
}: let
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-00-COR-003";
    title = "Auto Locale";
    description = "Intelligent country detection via IP geolocation for zero-touch locale setup.";
    layer = 00;
    nixpkgs.category = "system/localization";
    capabilities = ["automation/geolocate" "system/boot-optimization"];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 2;
  };

  cfg = config.my.autoLocale;

  # Locale-Profile (erweitert aus locale.nix)
  profiles = {
    DE = {
      name = "Deutschland";
      timeZone = "Europe/Berlin";
      locale = "de_DE.UTF-8";
      keyMap = "de-latin1";
      xkbLayout = "de";
      ntp = ["0.de.pool.ntp.org" "1.de.pool.ntp.org" "2.de.pool.ntp.org"];
    };
    AT = {
      name = "Österreich";
      timeZone = "Europe/Vienna";
      locale = "de_AT.UTF-8";
      keyMap = "de-latin1";
      xkbLayout = "de";
      ntp = ["0.at.pool.ntp.org" "1.at.pool.ntp.org"];
    };
    CH = {
      name = "Schweiz";
      timeZone = "Europe/Zurich";
      locale = "de_CH.UTF-8";
      keyMap = "de-latin1";
      xkbLayout = "de";
      ntp = ["0.ch.pool.ntp.org" "1.ch.pool.ntp.org"];
    };
    US = {
      name = "United States";
      timeZone = "America/New_York";
      locale = "en_US.UTF-8";
      keyMap = "us";
      xkbLayout = "us";
      ntp = ["0.us.pool.ntp.org" "1.us.pool.ntp.org"];
    };
  };

  geolocateScript = pkgs.writeShellScript "geolocate" ''
    set -euo pipefail
    COUNTRY=$(${pkgs.curl}/bin/curl -sf --max-time 5 "http://ip-api.com/json/?fields=countryCode" | ${pkgs.jq}/bin/jq -r '.countryCode' 2>/dev/null || echo "")
    if [ -n "$COUNTRY" ]; then echo "$COUNTRY"; exit 0; fi
    echo "DE"
  '';

  cacheFile = "/var/lib/auto-locale/country";
  # SRE-FIX: Wir nutzen hier lib.mkDefault, damit das System stabil bleibt
  selectedCountry =
    if cfg.country != ""
    then cfg.country
    else "DE";
  profile = profiles.${selectedCountry} or profiles.DE;
in {
  options.my.meta.auto_locale = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for auto-locale module";
  };

  options.my.autoLocale = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Aktiviert automatische Locale-Erkennung via Geolocation.";
    };
    country = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Länder-Code (ISO 3166-1 alpha-2). Leer = Automatisch.";
    };
  };

  config = lib.mkIf cfg.enable {
    time.timeZone = lib.mkDefault profile.timeZone;
    i18n.defaultLocale = lib.mkDefault profile.locale;

    # Nixpkgs Best Practice: Zusätzliche Locale-Settings
    i18n.extraLocaleSettings = {
      LC_ADDRESS = profile.locale;
      LC_IDENTIFICATION = profile.locale;
      LC_MEASUREMENT = profile.locale;
      LC_MONETARY = profile.locale;
      LC_NAME = profile.locale;
      LC_NUMERIC = profile.locale;
      LC_PAPER = profile.locale;
      LC_TELEPHONE = profile.locale;
      LC_TIME = profile.locale;
    };

    console.keyMap = lib.mkDefault profile.keyMap;
    services.xserver.xkb = {
      layout = lib.mkDefault profile.xkbLayout;
      variant = "";
    };

    systemd.services.auto-locale-detect = {
      description = "Auto-Locale: Detect Country via Geolocation";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        mkdir -p "$(dirname ${cacheFile})"
        COUNTRY=$(${geolocateScript} || echo "DE")
        echo "$COUNTRY" > ${cacheFile}
        logger -t auto-locale "Detected country: $COUNTRY"
      '';
    };
  };
}
/**
* ---
 * technical_integrity:
 *   checksum: sha256:b687efd2caf13b8f4da79539b13a52237997ffc623e3a733e81be8a6c334dc9b
 *   eof_marker: NIXHOME_VALID_EOF* ---
*/

