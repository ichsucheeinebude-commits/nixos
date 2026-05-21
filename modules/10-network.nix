# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-001"
# title: "Network Configuration"
# type: module
# status: draft
# complexity: 2
# reviewed: YYYY-MM-DD
# tags:
#   - network
#   - dns
#   - tailscale
# description: "DNS, Tailscale, interface configuration"
# provides:
#   - my.network.enable
# requires:
#   - 00-core
# links:
#   adr: ADR-10-network.md
#   guide: 10-network.md
#   module: modules/10-network.nix
# ---
# ---ENDNIXMETA

---
#
# PURPOSE: DNS, Tailscale, interface configuration.
# Key decisions: docs/adr/ADR-10-network.md

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
