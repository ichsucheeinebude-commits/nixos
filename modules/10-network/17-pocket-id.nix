# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-008"
# title: "Pocket-ID"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [network,oidc,auth,pocket-id]
# description: "Pocket-ID OIDC provider for SSO."
# path: "modules/10-network/17-pocket-id.nix"
# provides: [my.network.pocketId]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/10-network/17-pocket-id.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Wir benötigen eine robuste Namensauflösung für Dienste auf dem Tower, die sowohl lokal als auch im Tailnet ohne manuelle IP-Eingabe funktioniert.
# ### Entscheidung
#
# Wir implementieren das **Tailscale SplitDNS Pattern**:
# 1.  **MagicDNS:** Aktivierung für alle Tailnet-Geräte (SSoT für Hostnamen).
# 2.  **Global Nameserver:** Der Tower (AdGuardHome) wird als globaler Nameserver im Tailscale-Admin-Panel hinterlegt.
# 3.  **SplitDNS Regel:** Alle Anfragen an `<DOMAIN>` werden explizit an die Tailscale-IP des Towers geroutet.
# ─── End KB Nuggets ───

{ config, lib, ... }:
{
  options.my.network.pocketId = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    issuerUrl = lib.mkOption { type = lib.types.str; default = ""; };
  };

  config = lib.mkIf config.my.network.pocketId.enable {
    services.pocket-id = {
      enable = true;
      settings = {
        public_registration = false;
      };
    };
  };
}
