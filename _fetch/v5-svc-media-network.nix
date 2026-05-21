# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-AUTO-GEN",
#   "title": "Auto Generated",
#   "layer": 99,
#   "category": "auto/gen",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["auto-generated"],
#   "description": "Auto-migrated module to NIXMETA 2.0."
# }
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
let
  cfg = config.my.configs.network;
  nsName = "media-ns";
  
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-SER-NET-001";
    title = "Media Stack Network Segmentation";
    description = "Declarative network namespace and veth plumbing for media services.";
    layer = 20;
    capabilities = ["network/netns" "security/isolation"];
    audit.last_reviewed = "2026-05-12";
  };
in {
  options.my.meta.media_network = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
  };

  config = {
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
        ${pkgs.iproute2}/bin/ip addr add ${cfg.mediaGateway}/24 dev veth-media || true
        ${pkgs.iproute2}/bin/ip link set veth-media up

        # Assign IP and setup interface inside the namespace (eth0)
        ${pkgs.iproute2}/bin/ip -n ${nsName} addr add 10.200.0.2/24 dev eth0 || true
        ${pkgs.iproute2}/bin/ip -n ${nsName} link set eth0 up
        ${pkgs.iproute2}/bin/ip -n ${nsName} link set lo up

        # Set default gateway inside the namespace to point to the host
        ${pkgs.iproute2}/bin/ip -n ${nsName} route add default via ${cfg.mediaGateway} || true
      '';
      postStop = ''
        ${pkgs.iproute2}/bin/ip link del veth-media || true
        ${pkgs.iproute2}/bin/ip netns del ${nsName} || true
      '';
    };

    # Enable IP forwarding for NAT and routing
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    # 🛡️ NAT MASQUERADE (KRIT-04)
    networking.nftables.tables.media-nat = {
      family = "inet";
      content = ''
        chain postrouting {
          type nat hook postrouting priority 100;
          ip saddr 10.200.0.0/24 oifname != "veth-media" masquerade
        }
      '';
    };
  };
}
