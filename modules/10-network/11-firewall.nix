# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-002"
# title: "NFTables Firewall"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [network,firewall,nftables]
# description: "NFTables firewall with LAN trust and public port rules."
# path: "modules/10-network/11-firewall.nix"
# provides: [my.network.firewall]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/10-network/11-firewall.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.network.firewall = {
    enable = lib.mkOption { type = lib.types.bool; default = true; };
    allowedTCPPorts = lib.mkOption { type = lib.types.listOf lib.types.port; default = [ 80 443 ]; };
    allowedUDPPorts = lib.mkOption { type = lib.types.listOf lib.types.port; default = []; };
  };

  config = lib.mkIf config.my.network.firewall.enable {
    networking.firewall = {
      enable = true;
      allowedTCPPorts = config.my.network.firewall.allowedTCPPorts;
      allowedUDPPorts = config.my.network.firewall.allowedUDPPorts;
    };
    networking.nftables.enable = true;
  };
}
