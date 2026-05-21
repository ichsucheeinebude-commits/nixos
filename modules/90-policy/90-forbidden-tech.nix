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

# ─── KB Nuggets ───
# ### Kontext
#
# Das Ziel ist ein "Zero-to-Hero" Erlebnis für Self-Hoster. Ein Nutzer soll ohne tiefes Nix-Wissen einen gehärteten Server in Minuten in Betrieb nehmen können.
# ### Der Deployment-Workflow
#
# 1. **Clone:** `git clone https://github.com/grapefruit89/mynixos`
# 2. **Configure:** Ausfüllen der `USER_CONFIG.nix` und `secrets.sops.yaml`.
# 3. **Deploy:** `nixos-anywhere --flake .#default <IP>`
#
# > [LIVE-ENRICHMENT]: Die Integration von **nixos-anywhere** in Kombination mit **disko** (deklarative Partitionierung) ermöglicht die vollständige Automatisierung von einer leeren Festplatte bis zum fertig konfigurierten Caddy-Proxy inkl. TLS.
# ─── End KB Nuggets ───

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
