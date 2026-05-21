# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-010"
# title: "Zigbee Stack"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [network,zigbee,mqtt,iot]
# description: "Mosquitto MQTT broker + Zigbee2MQTT."
# path: "modules/10-network/19-zigbee-stack.nix"
# provides: [my.network.zigbeeStack]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/10-network/19-zigbee-stack.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.network.zigbeeStack = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    mqttPort = lib.mkOption { type = lib.types.port; default = 1883; };
    zigbeePort = lib.mkOption { type = lib.types.port; default = 8089; };
    zigbeeDevice = lib.mkOption { type = lib.types.str; default = ""; description = "Zigbee adapter path or socket URL."; };
    adapter = lib.mkOption {
      type = lib.types.enum [ "ember" "zstack" "deconz" "ezsp" ];
      default = "ember";
    };
    dataDir = lib.mkOption { type = lib.types.str; default = "/var/lib/zigbee2mqtt"; };
  };

  config = lib.mkIf config.my.network.zigbeeStack.enable {
    services.mosquitto = {
      enable = true;
      listeners = [{
        port = config.my.network.zigbeeStack.mqttPort;
        address = "127.0.0.1";
        acl = [ "pattern readwrite #" ];
        settings.allow_anonymous = true;
      }];
    };
    services.zigbee2mqtt = {
      enable = true;
      dataDir = config.my.network.zigbeeStack.dataDir;
      settings = {
        permit_join = false;
        mqtt = {
          base_topic = "zigbee2mqtt";
          server = "mqtt://127.0.0.1:${toString config.my.network.zigbeeStack.mqttPort}";
        };
        serial = {
          port = config.my.network.zigbeeStack.zigbeeDevice;
          adapter = config.my.network.zigbeeStack.adapter;
        };
        frontend = {
          port = config.my.network.zigbeeStack.zigbeePort;
          host = "127.0.0.1";
        };
      };
    };
  };
}
