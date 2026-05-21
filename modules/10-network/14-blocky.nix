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
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/10-network/14-blocky.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.network.blocky = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 53; };
    metricsPort = lib.mkOption { type = lib.types.port; default = 4000; };
    upstreamDns = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "1.1.1.1" "8.8.8.8" ]; };
    blockingLists = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
  };

  config = lib.mkIf config.my.network.blocky.enable {
    services.blocky = {
      enable = true;
      settings = {
        ports = { dns = config.my.network.blocky.port; http = config.my.network.blocky.metricsPort; };
        upstreams.groups.default = config.my.network.blocky.upstreamDns;
      };
    };
  };
}
