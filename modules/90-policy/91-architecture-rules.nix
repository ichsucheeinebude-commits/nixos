# ---NIXMETA
# ---
# domain: 90
# id: "NIXH-90-POL-002"
# title: "Architecture Rules"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [policy,architecture,guard]
# description: "Architectural guard rails via build-time assertions."
# path: "modules/90-policy/91-architecture-rules.nix"
# provides: [my.policy.architecture]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/90-policy/91-architecture-rules.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.policy.architecture = {
    enforce = lib.mkOption { type = lib.types.bool; default = true; };
  };

  config = lib.mkIf config.my.policy.architecture.enforce {
    assertions = [
      { assertion = !(config.virtualisation.docker.enable or false); message = "ARCH-FAIL: Docker forbidden."; }
      { assertion = !(config.services.tailscale.enable or false); message = "ARCH-FAIL: Tailscale forbidden."; }
      { assertion = !(config.services.cron.enable or false); message = "ARCH-FAIL: Cron forbidden."; }
      { assertion = config.networking.nftables.enable; message = "ARCH-FAIL: nftables mandatory."; }
    ];
  };
}
