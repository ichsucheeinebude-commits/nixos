# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-004"
# title: "Home Assistant"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [apps,home-assistant,iot]
# description: "Home Assistant IoT platform."
# path: "modules/60-apps/63-home-assistant.nix"
# provides: [my.apps.homeAssistant]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/60-apps/63-home-assistant.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.apps.homeAssistant = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 8123; };
  };
}
