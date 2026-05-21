# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-AUTO-GEN",
#   "title": "Auto Generated",
#   "layer": 99,
#   "category": "auto/gen",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["auto-generated"],
#   "description": "Auto-migrated module to NIXMETA 2.0."
# }
# ---ENDNIXMETA

{ config, lib, pkgs, myLib, ... }:
let
 # 🚀 NMS v4.2 Metadaten (hardened Zigbee Stack)
 # Fragment-Sourcing:
 # - NIXH-20-INF-004: Basis Zigbee-Stack Modul
 # - Fragment 3108: hardening
 # - ADR 852: ABC-Tiering Path Strategy
 nms = {
 id = "NIXH-01-SRV-ZIG-001";
 title = "Zigbee Stack (Mosquitto & Z2M)";
 description = "Hardened Zigbee infrastructure with Mosquitto Broker and Zigbee2MQTT.";
 layer = 20;
 nixpkgs.category = "services/home-automation";
 capabilities = ["iot/zigbee" "iot/mqtt" "security/sandboxing"];
 audit.last_reviewed = "2026-04-27";
 audit.complexity = 3;
 };

 cfg = config.my.services.zigbeeStack;
 srePaths = config.my.configs.paths;
 sreConfig = config.my.configs;

 # Logik für USB-Geräte
 isUsbDevice = lib.hasPrefix "/dev/" cfg.zigbeeDevice;

in
{
 options.my.meta.zigbee_stack = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 };

 options.my.services.zigbeeStack = {
 enable = lib.mkEnableOption "Zigbee Stack (Mosquitto + Zigbee2MQTT)";
 
 mqttPort = lib.mkOption { 
 type = lib.types.port; 
 default = config.my.ports.mqtt or 1883; 
 description = "Internal MQTT Broker Port";
 };

 zigbeePort = lib.mkOption { 
 type = lib.types.port; 
 default = config.my.ports.zigbee2mqtt; 
 description = "Zigbee2MQTT Frontend Port";
 };

 zigbeeDevice = lib.mkOption { 
 type = lib.types.str; 
 default = "socket://${config.my.configs.network.lanIP}:6638"; 
 description = "Zigbee adapter path (e.g. /dev/ttyUSB0) or socket (SLZB-06)";
 };

 adapter = lib.mkOption {
 type = lib.types.enum [ "ember" "zstack" "deconz" "ezsp" ];
 default = "ember";
 description = "Zigbee adapter type (ember for modern SLZB-06/Sonoff P)";
 };

 dataDir = lib.mkOption { 
 type = lib.types.str; 
 default = "${srePaths.stateDir}/zigbee2mqtt"; 
 description = "State directory for Zigbee2MQTT (Tier A/Persist)";
 };
 };

 config = lib.mkIf cfg.enable (lib.mkMerge [
 
 # 🌐 1. CADDY INTEGRATION (Frontend)
 (myLib.mkService {
 inherit config;
 name = "zigbee2mqtt";
 port = cfg.zigbeePort;
 useSSO = true;
 description = "Zigbee2MQTT Frontend";
 persist = true;
 readWritePaths = [ cfg.dataDir ];
 })

 {
 # 🦟 2. MOSQUITTO (MQTT BROKER)
 services.mosquitto = {
 enable = true;
 listeners = [{
 port = cfg.mqttPort;
 address = "127.0.0.1"; # hardened: Only local access
 acl = [ "pattern readwrite #" ];
 settings.allow_anonymous = true;
 }];
 };

 systemd.services.mosquitto.serviceConfig = {
 ProtectSystem = "strict";
 ProtectHome = true;
 PrivateTmp = true;
 NoNewPrivileges = true;
 ReadWritePaths = [ "/var/lib/mosquitto" ];
 OOMScoreAdjust = -100;
 };

 # 🐝 3. ZIGBEE2MQTT
 services.zigbee2mqtt = {
 enable = true;
 dataDir = cfg.dataDir;
 settings = {
 homeassistant = true;
 permit_join = false;
 mqtt = {
 base_topic = "zigbee2mqtt";
 server = "mqtt://127.0.0.1:${toString cfg.mqttPort}";
 };
 serial = {
 port = cfg.zigbeeDevice;
 adapter = cfg.adapter;
 };
 frontend = {
 port = cfg.zigbeePort;
 host = "127.0.0.1";
 };
 advanced = {
 log_directory = "${cfg.dataDir}/log";
 pan_id = 0x1a2b; # hardened: Custom PAN-ID (Source: Fragment 18968)
 };
 };
 };

 systemd.services.zigbee2mqtt = {
 after = [ "mosquitto.service" ];
 wants = [ "mosquitto.service" ];
 
 serviceConfig = {
 ProtectSystem = "strict";
 ProtectHome = true;
 PrivateTmp = true;
 NoNewPrivileges = true;
 
 # Device Access logic (Source: Fragment 2000)
 PrivateDevices = if isUsbDevice then lib.mkForce false else true;
 DeviceAllow = lib.optional isUsbDevice "${cfg.zigbeeDevice} rw";

 RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
 };
 };

 # 📁 PERMISSION MANAGEMENT
 systemd.tmpfiles.rules = [
 "d ${cfg.dataDir} 0750 zigbee2mqtt mqtt -"
 "d /var/lib/mosquitto 0750 mosquitto mqtt -"
 ];

      # Group alignment      users.groups.mqtt = {};
      users.users.zigbee2mqtt.extraGroups = [ "mqtt" "dialout" ];
      users.users.mosquitto.extraGroups = [ "mqtt" ];
    }
  ]);
}
/**
 * ---\n * technical_integrity:\n * checksum: sha256:d13a9c7b9600bfbd98bc1057589bcf25b5b1b8aa890de35898f63eb3211fd04f9\n * eof_marker: NIXHOME_VALID_EOF* ---\n */
