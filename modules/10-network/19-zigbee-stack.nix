# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-ZIG-001"
# title: "Zigbee/MQTT Stack"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [zigbee, mqtt]
# description: "Zigbee/MQTT Stack module."
# path: "modules/10-network/19-zigbee-stack.nix"
# provides: [my.network.zigbee]
# requires: [10-network/10-network]
# links:
#   adr: docs/adr/ADR-10-zigbee-stack.md
#   guide: docs/guides/10-zigbee-stack.md
#   module: modules/10-network/19-zigbee-stack.nix
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, myLib, ... }:
let
 # - NIXH-20-INF-004: Basis Zigbee-Stack Modul
 # - Fragment 3108: hardening
 # - ADR 852: ABC-Tiering Path Strategy

 cfg = config.my.services.zigbeeStack;
 srePaths = config.my.configs.paths;
 sreConfig = config.my.configs;

 isUsbDevice = lib.hasPrefix "/dev/" cfg.zigbeeDevice;

in
{

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
