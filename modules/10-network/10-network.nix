# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-001"
# title: "Network Configuration"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [network,systemd-resolved]
# description: "Base networking: systemd-resolved, DNS servers, host name."
# path: "modules/10-network/10-network.nix"
# provides: [my.network.base]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/10-network/10-network.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.network.base = {
    hostName = lib.mkOption { type = lib.types.str; default = ""; };
    nameservers = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "1.1.1.1" "8.8.8.8" ]; };
    enableResolved = lib.mkOption { type = lib.types.bool; default = true; };
  };

  config = lib.mkIf config.my.network.base.enableResolved {
    networking = {
      hostName = lib.mkIf (config.my.network.base.hostName != "") config.my.network.base.hostName;
      nameservers = config.my.network.base.nameservers;
    };
    services.resolved = {
      enable = true;
      dnssec = "allow-downgrade";
    };
  };
}
