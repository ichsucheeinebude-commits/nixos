# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-10-NET-001",
#   "title": "Network Configuration",
#   "layer": 10,
#   "category": "network",
#   "lastReviewed": "YYYY-MM-DD",
#   "reviewedBy": "moritz",
#   "status": "draft",
#   "complexity": 2,
#   "description": "DNS, Tailscale, interface configuration",
#   "tags": ["network", "dns", "tailscale"]
# }
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

# ── Network Module ────────────────────────────────────────────────────
# DNS, Tailscale, interfaces

let
  cfg  = config.my.network;
  core = config.my.core;
in {

  options.my.network = {
    enable = lib.mkEnableOption "network module";
  };

  config = lib.mkIf cfg.enable {

    # ── DNS (DoH Fallback) ──────────────────────────────────────────
    networking.nameservers = [ "9.9.9.9" "1.1.1.1" ];

    # ── Tailscale ───────────────────────────────────────────────────
    services.tailscale.enable = true;

    # ── Firewall Rules ──────────────────────────────────────────────
    # (anchor: network-firewall)
    networking.firewall.trustedInterfaces = [ "tailscale0" "lo" ];
  };
}
