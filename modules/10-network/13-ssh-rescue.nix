# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-004"
# title: "SSH Rescue"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [network,ssh,rescue]
# description: "Secondary SSH service for emergency access."
# path: "modules/10-network/13-ssh-rescue.nix"
# provides: [my.network.sshRescue]
# requires: []
# links:
#   adr: docs/adr/ADR-10-network.md
#   guide: docs/guides/10-network.md
#   module: modules/10-network/13-ssh-rescue.nix
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
  options.my.network.sshRescue = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 2222; };
    authorizedKeys = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
  };

  config = lib.mkIf config.my.network.sshRescue.enable {
    systemd.services."sshd-rescue" = {
      description = "Rescue SSH Server";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${config.services.openssh.package}/bin/sshd -D -f /etc/ssh/sshd_config_rescue";
        Restart = "on-failure";
      };
    };
    environment.etc."ssh/sshd_config_rescue".text = ''
      Port ${toString config.my.network.sshRescue.port}
      PermitRootLogin no
      PasswordAuthentication no
      PubkeyAuthentication yes
    '';
  };
}
