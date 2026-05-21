# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-009"
# title: "DDNS Updater"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [network,ddns,dynamic-dns]
# description: "Dynamic DNS updates."
# path: "modules/10-network/18-ddns-updater.nix"
# provides: [my.network.ddnsUpdater]
# requires: []
# links:
#   adr: docs/adr/ADR-18-ddns-updater.md
#   guide: docs/guides/18-ddns-updater.md
#   module: modules/10-network/18-ddns-updater.nix
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
  options.my.network.ddnsUpdater = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 8080; };
    period = lib.mkOption { type = lib.types.str; default = "10m"; };
  };

  config = lib.mkIf config.my.network.ddnsUpdater.enable {
    services.ddns-updater = {
      enable = true;
      environment = {
        LISTENING_ADDRESS = ":${toString config.my.network.ddnsUpdater.port}";
        PERIOD = config.my.network.ddnsUpdater.period;
      };
    };
  };
}
