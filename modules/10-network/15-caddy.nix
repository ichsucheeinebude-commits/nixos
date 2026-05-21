# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-006"
# title: "Caddy Reverse Proxy"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [network,caddy,reverse-proxy]
# description: "Caddy as reverse proxy with automatic TLS."
# path: "modules/10-network/15-caddy.nix"
# provides: [my.network.caddy]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/10-network/15-caddy.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.network.caddy = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    email = lib.mkOption { type = lib.types.str; default = ""; };
    virtualHosts = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = {};
    };
  };

  config = lib.mkIf config.my.network.caddy.enable {
    services.caddy = {
      enable = true;
      email = lib.mkIf (config.my.network.caddy.email != "") config.my.network.caddy.email;
      virtualHosts = config.my.network.caddy.virtualHosts;
    };
  };
}
