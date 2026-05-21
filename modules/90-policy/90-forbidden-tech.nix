# ---NIXMETA
# ---
# domain: 90
# id: "NIXH-90-POL-001"
# title: "Forbidden Technology"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [policy,forbidden,assertions]
# description: "Zero-tolerance assertions against forbidden technologies."
# path: "modules/90-policy/90-forbidden-tech.nix"
# provides: [my.policy.forbidden]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/90-policy/90-forbidden-tech.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.policy.forbidden = {
    enforce = lib.mkOption { type = lib.types.bool; default = true; };
  };

  config = lib.mkIf (config.my.policy.forbidden.enforce && !config.my.core.principles.bastelmodus) {
    assertions = [
      { assertion = !(config.boot.lanzaboote.enable or false); message = "Forbidden: Lanzaboote."; }
      { assertion = !(config.services.tailscale.enable or false); message = "Forbidden: Tailscale."; }
      { assertion = !(config.virtualisation.docker.enable or false); message = "Forbidden: Docker. Use native systemd services."; }
      { assertion = !(config.services.cron.enable or false); message = "Forbidden: Cron. Use systemd timers."; }
      { assertion = config.networking.nftables.enable; message = "Forbidden: Legacy iptables. Use nftables."; }
      { assertion = !(config.services.sftpgo.enable or false); message = "Forbidden: SFTPGo."; }
    ];
  };
}
