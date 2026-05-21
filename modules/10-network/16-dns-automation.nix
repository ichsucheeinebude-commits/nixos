# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-007"
# title: "DNS Automation"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [network,dns,cloudflare]
# description: "Cloudflare DNS conflict detection and runtime map generation."
# path: "modules/10-network/16-dns-automation.nix"
# provides: [my.network.dnsAutomation]
# requires: []
# links:
#   adr: docs/adr/ADR-16-dns-automation.md
#   guide: docs/guides/16-dns-automation.md
#   module: modules/10-network/16-dns-automation.nix
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

{ config, lib, pkgs, ... }:
{
  options.my.network.dnsAutomation = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    runtimeMap = lib.mkOption { type = lib.types.str; default = "/var/lib/nixhome/dns-map-runtime.json"; };
  };

  config = lib.mkIf config.my.network.dnsAutomation.enable {
    systemd.services.dns-guard = {
      description = "Check Cloudflare for DNS conflicts";
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        StateDirectory = "nixhome";
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        ExecStart = pkgs.writeShellScript "dns-guard-runtime" ''
          set -euo pipefail
          echo '{"useNixSubdomain":false,"baseDomain":"PLACEHOLDER"}' > "${config.my.network.dnsAutomation.runtimeMap}"
        '';
      };
    };
    systemd.timers.dns-guard = {
      wantedBy = [ "timers.target" ];
      timerConfig = { OnBootSec = "1min"; OnUnitActiveSec = "30min"; };
    };
  };
}
