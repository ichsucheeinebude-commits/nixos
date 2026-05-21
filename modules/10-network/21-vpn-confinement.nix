# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-20-INF-007"
# title: "VPN Confinement"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-21
# tags: [vpn,network-namespace,wireguard,isolation,confinement]
# description: "Network namespace based VPN isolation for secure service routing."
# path: "modules/10-network/21-vpn-confinement.nix"
# provides: [my.networking.vpnConfinement]
# requires: [10-network]
# links:
#   module: modules/10-network/21-vpn-confinement.nix
# source: _meta/20-infrastructure/vpn-confinement.nix (NIXH-20-INF-007)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
  cfg = config.my.networking.vpnConfinement;
  nsName = cfg.namespaceName;
  hostIP = cfg.hostIP;
  vaultIP = cfg.vaultIP;
  wgKey = cfg.wgPrivateKeyFile;
  vpnConfig = cfg.vpn;
in
{
  options.my.networking.vpnConfinement = {
    enable = lib.mkEnableOption "VPN network namespace isolation";
    namespaceName = lib.mkOption { type = lib.types.str; default = "media-vault"; };
    hostIP = lib.mkOption { type = lib.types.str; default = "10.200.1.1"; };
    vaultIP = lib.mkOption { type = lib.types.str; default = "10.200.1.2"; };
    wgPrivateKeyFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/secrets/wg_privado_private_key";
      description = "Path to WireGuard private key file.";
    };
    vpn = {
      publicKey = lib.mkOption { type = lib.types.str; default = ""; };
      endpoint = lib.mkOption { type = lib.types.str; default = ""; };
      address = lib.mkOption { type = lib.types.str; default = ""; };
      dns = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      { assertion = vpnConfig.dns != []; message = "vpn-confinement: DNS must not be empty."; }
      { assertion = vpnConfig.publicKey != ""; message = "vpn-confinement: publicKey must be set."; }
    ];

    systemd.services."netns-${nsName}" = {
      description = "Network Namespace: ${nsName}";
      before = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "setup-vault-ns" ''
          ip netns add ${nsName} || true
          ip link add veth-${nsName} type veth peer name veth-${nsName}-ns
          ip link set veth-${nsName} up
          ip link set veth-${nsName}-ns netns ${nsName}
          ip addr add ${hostIP}/30 dev veth-${nsName}
          ip netns exec ${nsName} ip addr add ${vaultIP}/30 dev veth-${nsName}-ns
          ip netns exec ${nsName} ip link set veth-${nsName}-ns up
          ip netns exec ${nsName} ip link set lo up
          ip netns exec ${nsName} ip route add default via ${hostIP}
          iptables -t nat -A POSTROUTING -s ${vaultIP}/30 -o eth0 -j MASQUERADE
          echo 1 > /proc/sys/net/ipv4/ip_forward
        '';
      };
    };

    systemd.services.wireguard-vault = {
      description = "WireGuard VPN inside ${nsName}";
      after = [ "netns-${nsName}.service" "network-online.target" ];
      requires = [ "netns-${nsName}.service" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "30s";
      };
      path = [ pkgs.wireguard-tools pkgs.coreutils pkgs.iproute2 ];
      script = ''
        set -euo pipefail
        ip netns exec ${nsName} wg addconf wg0 ${wgKey}
        ip netns exec ${nsName} ip addr add ${vpnConfig.address} dev wg0
        ip netns exec ${nsName} ip link set wg0 up
        ip netns exec ${nsName} ip route add 0.0.0.0/0 dev wg0 2>/dev/null || true
      '';
    };
  };
}
