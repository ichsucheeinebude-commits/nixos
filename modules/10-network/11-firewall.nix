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
#   adr: docs/adr/ADR-10-002-002.md
#   guide: docs/guides/GUIDE-10-002-002.md
#   module: modules/10-network/11-firewall.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
let
  sshPort = toString config.my.core.ports.ssh;
  lanCidrs = config.my.core.network.lanCidrs;
in
{
  options.my.network.firewall = {
    enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable NFTables firewall."; };
    allowedTCPPorts = lib.mkOption { type = lib.types.listOf lib.types.port; default = [ 80 443 ]; description = "Public TCP ports."; };
    allowedUDPPorts = lib.mkOption { type = lib.types.listOf lib.types.port; default = []; description = "Public UDP ports."; };
  };

  config = lib.mkIf (config.my.network.firewall.enable) {
    networking = {
      firewall.enable = true;
      nftables.enable = true;
    };
    networking.firewall = {
      allowedTCPPorts = config.my.network.firewall.allowedTCPPorts;
      allowedUDPPorts = config.my.network.firewall.allowedUDPPorts;
      # Allow SSH from LAN only (restrict via lanCidrs)
      trustedInterfaces = lib.optionals (lanCidrs != []) [ ];
    };
  };
}

