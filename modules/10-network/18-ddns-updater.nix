# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-009"
# title: "DDNS Updater"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [network,ddns,dynamic-dns]
# description: "Dynamic DNS updates."
# path: "modules/10-network/18-ddns-updater.nix"
# provides: [my.network.ddnsUpdater]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/10-network/18-ddns-updater.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.network.ddnsUpdater = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 8080; };
    period = lib.mkOption { type = lib.types.str; default = "10m"; };
  };

  config = lib.mkIf config.my.network.ddnsUpdater.enable {
    services.ddns-updater = {
      enable = true;
      environment = {
        LISTENING_ADDRESS = ":${toString config.my.network.ddnsUpdater.port}";
        PERIOD = config.my.network.ddnsUpdater.period;
      };
    };
  };
}
