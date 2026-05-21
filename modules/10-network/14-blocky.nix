# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-005"
# title: "Blocky DNS"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [network,dns,blocky]
# description: "Blocky DNS server with ad-blocking."
# path: "modules/10-network/14-blocky.nix"
# provides: [my.network.blocky]
# requires: []
# links:
#   adr: docs/adr/ADR-10-005-005.md
#   guide: docs/guides/GUIDE-10-005-005.md
#   module: modules/10-network/14-blocky.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.network.blocky = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Blocky DNS."; };
    port = lib.mkOption { type = lib.types.port; default = 53; description = "DNS listening port."; };
    metricsPort = lib.mkOption { type = lib.types.port; default = 4000; description = "Metrics port."; };
    upstreamDns = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "1.1.1.1" "8.8.8.8" ]; description = "Upstream DNS servers."; };
    blockingLists = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "Ad-block list URLs."; };
  };

  config = lib.mkIf config.my.network.blocky.enable {
    services.blocky = {
      enable = true;
      settings = {
        ports = { dns = config.my.network.blocky.port; http = config.my.network.blocky.metricsPort; };
        upstreams.groups.default = config.my.network.blocky.upstreamDns;
        blocking = lib.mkIf (config.my.network.blocky.blockingLists != []) {
          blackLists = { ads = config.my.network.blocking.blockingLists; };
          clientGroupsBlock.default = [ "ads" ];
        };
      };
    };
  };
}

