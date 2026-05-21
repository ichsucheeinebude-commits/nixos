{ lib, config, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-COR-020";
    title = "Locale (SRE Refactored)";
    description = "Centralized localization settings using the Master Source of Truth.";
    layer = 00;
    nixpkgs.category = "system/localization";
    capabilities = [ "system/localization" "ssot/locale" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 1;
  };

  tz = config.my.configs.locale.timezone;
  loc = config.my.configs.locale.default;
in
{
  options.my.meta.locale = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for locale module";
  };

  config = {
    time.timeZone = tz;
    i18n.defaultLocale = loc;
    i18n.supportedLocales = lib.mkForce [ "de_DE.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
    
    console.keyMap = lib.mkForce "de-latin1";
    services.xserver.xkb = {
      layout = "de";
      variant = "";
    };

    networking.timeServers = [ 
      "0.de.pool.ntp.org" 
      "1.de.pool.ntp.org" 
      "2.de.pool.ntp.org" 
      "3.de.pool.ntp.org" 
    ];

    services.resolved = {
      enable = true;
      dnssec = "true";
      dnsovertls = "opportunistic";
      domains = [ "~." ];
    };
  };
}
