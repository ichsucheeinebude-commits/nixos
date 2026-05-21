# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-026"
# title: "WireGuard Admin Tunnel"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [network,wireguard,vpn,admin,remote-access]
# description: "Single-peer WireGuard tunnel for remote admin access. Server private key loaded from SOPS secrets. Peers configured via options."
# path: "modules/10-network/26-wireguard-admin.nix"
# provides: [my.network.wireguard-admin]
# requires: [00-core]
# links:
#   module: modules/10-network/26-wireguard-admin.nix
# source: mynixos-v5/modules/services/wireguard-admin.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

let
  cfg = config.my.network.wireguard-admin;
in
{
  # ── WireGuard Admin Mini-Tunnel ──
  # Single-peer WireGuard tunnel for remote admin access.
  # Server private key loaded from SOPS; peers configured via options.

  options.my.network.wireguard-admin = {
    enable = lib.mkEnableOption "WireGuard admin mini-tunnel";
    port = lib.mkOption {
      type = lib.types.port;
      default = 51820;
      description = "WireGuard listen port.";
    };
    ips = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "10.100.0.1/24" ];
      description = "IP addresses for the WireGuard interface.";
    };
    sopsSecretPath = lib.mkOption {
      type = lib.types.path;
      default = ../../secrets/secrets.yaml;
      description = "Path to the SOPS secrets file containing the WireGuard private key.";
    };
    peers = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          publicKey = lib.mkOption {
            type = lib.types.str;
            description = "Peer's WireGuard public key.";
          };
          allowedIPs = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "10.100.0.2/32" ];
            description = "Allowed IPs for this peer.";
          };
        };
      });
      default = [];
      description = "WireGuard peers to allow.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.wireguard.interfaces = {
      wg-admin = {
        ips = cfg.ips;
        listenPort = cfg.port;
        privateKeyFile = config.sops.secrets.wireguard_admin_private_key.path;
        peers = map (peer: {
          publicKey = peer.publicKey;
          allowedIPs = peer.allowedIPs;
        }) cfg.peers;
      };
    };

    # Allow WireGuard UDP traffic through firewall
    networking.firewall.allowedUDPPorts = [ cfg.port ];

    # Sops Secret Definition
    sops.secrets.wireguard_admin_private_key = {
      sopsFile = cfg.sopsSecretPath;
      owner = "root";
    };

    # Restart WireGuard when secret changes
    systemd.services.wireguard-wg-admin.restartTriggers = [
      config.sops.secrets.wireguard_admin_private_key.path
    ];
  };
}
