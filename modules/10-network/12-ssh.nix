# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-003"
# title: "SSH Server"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [network,ssh,openssh]
# description: "OpenSSH server configuration."
# path: "modules/10-network/12-ssh.nix"
# provides: [my.network.ssh]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/10-network/12-ssh.nix
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
  options.my.network.ssh = {
    enable = lib.mkOption { type = lib.types.bool; default = true; };
    port = lib.mkOption { type = lib.types.port; default = 22; };
    passwordAuth = lib.mkOption { type = lib.types.bool; default = false; };
  };

  config = lib.mkIf config.my.network.ssh.enable {
    services.openssh = {
      enable = true;
      ports = [ config.my.network.ssh.port ];
      settings = {
        PasswordAuthentication = config.my.network.ssh.passwordAuth;
        PermitRootLogin = "no";
        KbdInteractiveAuthentication = false;
      };
    };
    my.core.ports.ssh = lib.mkDefault config.my.network.ssh.port;
  };
}
