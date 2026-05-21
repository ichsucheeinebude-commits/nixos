# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-HAS-001"
# title: "Home Assistant"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [home-assistant, iot]
# description: "Home Assistant module."
# path: "modules/60-apps/63-home-assistant.nix"
# provides: [my.apps.hass]
# requires: [10-network/10-network]
# links:
#   adr: docs/adr/ADR-60-home-assistant.md
#   guide: docs/guides/60-home-assistant.md
#   module: modules/60-apps/63-home-assistant.nix
# ---
# ---ENDNIXMETA

# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-030-AUT-HAS-001",
#   "title": "Home Assistant (hardened)",
#   "layer": 30,
#   "category": "services/home-automation",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 3,
#   "tags": ["home-automation", "hass", "iot", "mqtt", "hardened"],
#   "description": "Hardened Home Automation with ABC-Tiering and Secret-Isolation."
# }
# ---ENDNIXMETA

{ config, lib, pkgs, myLib, ... }:
let
 # 🚀 NMS v4.2 Metadaten (hardened Home Assistant)
 # Fragment-Sourcing:
 # - NIXH-30-AUT-003: Basis Home Assistant Modul
 # - Fragment 3108: hardening (Python exemptions)
 # - Fragment 3331: LoadCredential for Secrets
 # - ADR 852: ABC-Tiering Path Strategy

 cfg = config.my.apps.home-assistant;
 srePaths = config.my.configs.paths;
 sreConfig = config.my.configs;

 # Logik für USB-Geräte (Zigbee)
 isUsbDevice = lib.hasPrefix "/dev/" cfg.zigbeeDevice;

in
{
 options.my.meta.home_assistant = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 };

 options.my.apps.home-assistant = {
 enable = lib.mkEnableOption "Home Assistant (IoT)";
 user = lib.mkOption { type = lib.types.str; default = "hass"; };
 group = lib.mkOption { type = lib.types.str; default = "hass"; };
 port = lib.mkOption { type = lib.types.port; default = config.my.ports.homeAssistant or 8123; }; 
 # 💾 PATH STRATEGY (ABC-Tiering)
 stateDir = lib.mkOption { 
 type = lib.types.str; 
 default = "${srePaths.stateDir}/home-assistant"; 
 description = "Configuration and primary DB (Tier A/Persist)";
 };
 cacheDir = lib.mkOption {
 type = lib.types.str;
 default = "${srePaths.tierB}/cache/home-assistant";
 description = "Python bytecode and temp cache (Tier B)";
 };
 mediaDir = lib.mkOption {
 type = lib.types.str;
 default = "${srePaths.mediaLibrary}/home-assistant";
 description = "Media archive for recordings/snapshots (Tier C)";
 };

 # 📡 HARDWARE & INTEGRATION
 zigbeeDevice = lib.mkOption { 
 type = lib.types.str; 
 default = "socket://${config.my.configs.network.lanIP}:6638"; 
 description = "Zigbee adapter path or socket";
 };
 bluetooth = lib.mkOption { type = lib.types.bool; default = false; };
 
 # 🔑 SECRETS
 secretFile = lib.mkOption {
 type = lib.types.nullOr lib.types.path;
 default = null;
 description = "Path to HA Secrets (via Sops)";
 };
 };

 config = lib.mkIf cfg.enable (lib.mkMerge [
 # 🏆 Use the hardened Service Factory
 (myLib.mkService {
 inherit config;
 name = "home-assistant";
 port = cfg.port;
 useSSO = true;
 description = "Home Assistant Core";
 persist = true;
 extraServiceConfig = {
   IPAddressAllow = "any";
   # HA needs some devices for Zigbee/Bluetooth if not using netns
   PrivateDevices = lib.mkForce false;
 };
 readWritePaths = [ cfg.stateDir cfg.cacheDir cfg.mediaDir ];
 })

 {
 # 👥 USER & GROUP
 users.users.${cfg.user} = {
 isSystemUser = true;
 group = cfg.group;
 home = cfg.stateDir;
 extraGroups = [ "dialout" "video" "media" ] ++ (lib.optional cfg.bluetooth "bluetooth");
 };
 users.groups.${cfg.group} = {};

      # 🏠 HOME ASSISTANT IOT (anchor: home-assistant-iot)
      services.home-assistant = {
        enable = true;
        configDir = cfg.stateDir;
        extraComponents = [ 
          "default_config" "met" "esphome" "prometheus" "mobile_app" 
          "sun" "radio_browser" "google_translate" "mqtt" 
        ];
        config = {
          homeassistant = {
            name = "NixHome";
            unit_system = "metric";
            time_zone = sreConfig.locale.timezone;
            external_url = "https://home.${sreConfig.identity.subdomain}.${sreConfig.identity.domain}";
            internal_url = "http://localhost:${toString cfg.port}";
          };
          # MQTT Auto-Wiring
          mqtt = {
            broker = "127.0.0.1";
            port = config.my.ports.mqtt or 1883;
          };
          http = {
            use_x_forwarded_for = true;
            trusted_proxies = [ "127.0.0.1" "::1" ] ++ sreConfig.network.lanCidrs;
          };
        };
      };

 systemd.services.home-assistant = {
 description = "Home Assistant Core (hardened)";
 
 # 🔗 PYTHON CACHE REDIRECT (Source: Fragment 3192)
 environment.PYTHONPYCACHEPREFIX = "${cfg.cacheDir}/pycache";

 serviceConfig = {
 # 🔑 SECRET ISOLATION
 LoadCredential = lib.optional (cfg.secretFile != null) "HA_SECRET:${toString cfg.secretFile}";

 # 🛡️ hardening
 MemoryMax = "2G";
 CPUWeight = 70;
 OOMScoreAdjust = 300;
 
 ProtectSystem = "strict";
 ProtectHome = true;
 PrivateTmp = true;
 NoNewPrivileges = true;
 
 # Device Access
 PrivateDevices = if isUsbDevice || cfg.bluetooth then lib.mkForce false else true;
 DeviceAllow = (lib.optional isUsbDevice "${cfg.zigbeeDevice} rw")
 ++ (lib.optional cfg.bluetooth "/dev/rfkill rw")
 ++ [ "/dev/dri/renderD128 rw" ]; # Hardware Transcoding (selten gebraucht)

 RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
 SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
 };
 };

      # 📁 PERMISSION MANAGEMENT
      systemd.tmpfiles.rules = [
        "d ${cfg.stateDir} 0750 ${cfg.user} ${cfg.group} -"
        "d ${cfg.cacheDir} 0750 ${cfg.user} ${cfg.group} -"
        "d ${cfg.cacheDir}/pycache 0750 ${cfg.user} ${cfg.group} -"
        "d ${cfg.mediaDir} 0775 ${cfg.user} ${cfg.group} -"
      ];
    }
  ]);
}

