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
#   adr: docs/adr/ADR-91-architecture-rules.md
#   guide: docs/guides/91-architecture-rules.md
#   module: modules/90-policy/91-architecture-rules.nix
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
