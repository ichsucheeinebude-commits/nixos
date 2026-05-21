# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-005"
# title: "Blocky DNS"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [network,dns,blocky]
# description: "Blocky DNS server with ad-blocking."
# path: "modules/10-network/14-blocky.nix"
# provides: [my.network.blocky]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/10-network/14-blocky.nix
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
  options.my.network.blocky = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 53; };
    metricsPort = lib.mkOption { type = lib.types.port; default = 4000; };
    upstreamDns = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "1.1.1.1" "8.8.8.8" ]; };
    blockingLists = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
  };

  config = lib.mkIf config.my.network.blocky.enable {
    services.blocky = {
      enable = true;
      settings = {
        ports = { dns = config.my.network.blocky.port; http = config.my.network.blocky.metricsPort; };
        upstreams.groups.default = config.my.network.blocky.upstreamDns;
      };
    };
  };
}
