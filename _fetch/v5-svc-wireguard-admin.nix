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
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-10-GTW-015";
    title = "WireGuard Admin Mini-Tunnel";
    description = "Single-peer WireGuard tunnel for remote admin access (Decision H).";
    layer = 10;
    nixpkgs.category = "services/security";
    capabilities = ["network/vpn" "security/remote-admin"];
    audit.last_reviewed = "2026-05-10";
    audit.complexity = 2;
  };

  cfg = config.my.services.wireguard-admin;
  port = config.my.ports.wireguard;
in {
  options.my.meta.wireguard-admin = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
  };

  options.my.services.wireguard-admin = {
    enable = lib.mkEnableOption "WireGuard Admin Mini-Tunnel";
  };

  config = lib.mkIf cfg.enable {
    networking.wireguard.interfaces = {
      wg-admin = {
        ips = config.my.configs.network.adminVpnIPs;
        listenPort = port;
        # Server's private key loaded from SOPS
        privateKeyFile = config.sops.secrets.wireguard_admin_private_key.path;

        # peers = [
        #   {
        #     # Admin's primary device public key
        #     publicKey = "REPLACE_WITH_ADMIN_DEVICE_PUBLIC_KEY"; # TODO: Replace with actual key
        #     allowedIPs = [ "10.100.0.2/32" ];
        #   }
        # ];
      };
    };

    # Allow WireGuard traffic through firewall
    networking.firewall.allowedUDPPorts = [ port ];

    # Sops Secret Definition
    sops.secrets.wireguard_admin_private_key = {
      sopsFile = ../../secrets/secrets.yaml;
      owner = "root";
    };

    systemd.services.wireguard-wg-admin.restartTriggers = [
      config.sops.secrets.wireguard_admin_private_key.path
    ];
  };
}
