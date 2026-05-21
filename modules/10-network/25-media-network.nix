# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-025"
# title: "Media Network Namespace"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-22
# tags: [network,netns,media,isolation,veth]
# description: "Declarative network namespace isolation for media services. Creates dedicated netns with veth pair plumbing and NAT masquerade."
# path: "modules/10-network/25-media-network.nix"
# provides: [my.network.media-ns]
# requires: [00-core]
# links:
#   module: modules/10-network/25-media-network.nix
# source: mynixos-v5/modules/services/media-network.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

let
  cfg = config.my.network.media-ns;
  nsName = "media-ns";
in
{
  # ── Media Network Namespace ──
  # Isolates media services in a dedicated network namespace.
  # Uses veth pair for host ↔ ns communication with NAT masquerade.

  options.my.network.media-ns = {
    enable = lib.mkEnableOption "Media network namespace isolation";
    gatewayIP = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.1";
      description = "Host-side gateway IP for the media namespace.";
    };
    nsIP = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.2";
      description = "IP address assigned inside the media namespace.";
    };
    subnet = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.0/24";
      description = "CIDR subnet for the media namespace.";
    };
  };

  config = lib.mkIf cfg.enable {
    # ── Network Namespace Setup Service ──
    systemd.services."netns-${nsName}" = {
      description = "Network namespace for media services";
      before = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        CapabilityBoundingSet = [ "CAP_NET_ADMIN" "CAP_NET_RAW" "CAP_SYS_ADMIN" ];
        AmbientCapabilities = [ "CAP_NET_ADMIN" "CAP_NET_RAW" "CAP_SYS_ADMIN" ];
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        MemoryDenyWriteExecute = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK" ];
        ProtectSystem = "full";
        SystemCallFilter = [ "@system-service" "@network-io" "unshare" "setns" "~@resources" ];
      };

      script = ''
        # Create namespace if it doesn't exist
        ${pkgs.iproute2}/bin/ip netns add ${nsName} || true

        # Create veth pair (host <-> ns)
        ${pkgs.iproute2}/bin/ip link add veth-media type veth peer name eth0 || true

        # Move eth0 to the namespace
        ${pkgs.iproute2}/bin/ip link set eth0 netns ${nsName} || true

        # Assign IP to the host side (veth-media)
        ${pkgs.iproute2}/bin/ip addr add ${cfg.gatewayIP}/24 dev veth-media || true
        ${pkgs.iproute2}/bin/ip link set veth-media up

        # Assign IP and setup interface inside the namespace
        ${pkgs.iproute2}/bin/ip -n ${nsName} addr add ${cfg.nsIP}/24 dev eth0 || true
        ${pkgs.iproute2}/bin/ip -n ${nsName} link set eth0 up
        ${pkgs.iproute2}/bin/ip -n ${nsName} link set lo up

        # Set default gateway inside the namespace
        ${pkgs.iproute2}/bin/ip -n ${nsName} route add default via ${cfg.gatewayIP} || true
      '';

      postStop = ''
        ${pkgs.iproute2}/bin/ip link del veth-media || true
        ${pkgs.iproute2}/bin/ip netns del ${nsName} || true
      '';
    };

    # ── IP Forwarding for NAT ──
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    # ── NAT Masquerade ──
    networking.nftables.tables.media-nat = {
      family = "inet";
      content = ''
        chain postrouting {
          type nat hook postrouting priority 100;
          ip saddr ${cfg.subnet} oifname != "veth-media" masquerade
        }
      '';
    };
  };
}
