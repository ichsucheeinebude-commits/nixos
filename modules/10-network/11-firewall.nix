# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-002"
# title: "NFTables Firewall"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [network,firewall,nftables]
# description: "NFTables firewall with LAN trust and public port rules."
# path: "modules/10-network/11-firewall.nix"
# provides: [my.network.firewall]
# requires: []
# links:
#   adr: docs/adr/ADR-10-network.md
#   guide: docs/guides/10-network.md
#   module: modules/10-network/11-firewall.nix
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
  options.my.network.firewall = {
    enable = lib.mkOption { type = lib.types.bool; default = true; };
    allowedTCPPorts = lib.mkOption { type = lib.types.listOf lib.types.port; default = [ 80 443 ]; };
    allowedUDPPorts = lib.mkOption { type = lib.types.listOf lib.types.port; default = []; };
  };

  config = lib.mkIf config.my.network.firewall.enable {
    networking.firewall = {
      enable = true;
      allowedTCPPorts = config.my.network.firewall.allowedTCPPorts;
      allowedUDPPorts = config.my.network.firewall.allowedUDPPorts;
    };
    networking.nftables.enable = true;
  };
}
