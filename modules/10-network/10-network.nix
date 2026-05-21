# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-001"
# title: "Network Configuration"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [network,systemd-resolved]
# description: "Base networking: systemd-resolved, DNS servers, host name."
# path: "modules/10-network/10-network.nix"
# provides: [my.network.base]
# requires: []
# links:
#   adr: docs/adr/ADR-10-network.md
#   guide: docs/guides/10-network.md
#   module: modules/10-network/10-network.nix
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
# 3.  **SplitDNS Regel:** Alle Anfragen an `m7c5.de` werden explizit an die Tailscale-IP des Towers geroutet.
# ─── End KB Nuggets ───

{ config, lib, ... }:
{
  options.my.network.base = {
    hostName = lib.mkOption { type = lib.types.str; default = ""; };
    nameservers = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "1.1.1.1" "8.8.8.8" ]; };
    enableResolved = lib.mkOption { type = lib.types.bool; default = true; };
  };

  config = lib.mkIf config.my.network.base.enableResolved {
    networking = {
      hostName = lib.mkIf (config.my.network.base.hostName != "") config.my.network.base.hostName;
      nameservers = config.my.network.base.nameservers;
    };
    services.resolved = {
      enable = true;
      dnssec = "allow-downgrade";
    };
  };
}
