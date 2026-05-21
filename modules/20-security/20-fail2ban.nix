# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SEC-001"
# title: "Fail2ban"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [security,fail2ban,nftables]
# description: "Fail2ban with NFTables and Caddy log inspection."
# path: "modules/20-security/20-fail2ban.nix"
# provides: [my.security.fail2ban]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/20-security/20-fail2ban.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
let
  sshPort = toString config.my.core.ports.ssh;
in
{
  options.my.security.fail2ban = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    bantime = lib.mkOption { type = lib.types.str; default = "1h"; };
    maxretry = lib.mkOption { type = lib.types.int; default = 5; };
    banIncrementMaxtime = lib.mkOption { type = lib.types.str; default = "168h"; };
  };

  config = lib.mkIf config.my.security.fail2ban.enable {
    services.fail2ban = {
      enable = true;
      banaction = "nftables-multiport";
      bantime = config.my.security.fail2ban.bantime;
      maxretry = config.my.security.fail2ban.maxretry;
      bantime-increment = {
        enable = true;
        multipliers = "1 2 4 8 16 32 64";
        maxtime = config.my.security.fail2ban.banIncrementMaxtime;
      };
      jails = {
        sshd.settings = { enabled = true; port = sshPort; mode = "aggressive"; };
      };
    };
    environment.etc."fail2ban/filter.d/caddy-json.conf".text = ''
      [Definition]
      failregex = ^.*"remote_ip":"<ADDR>".*"status":(401|403).*$
      journalmatch = _SYSTEMD_UNIT=caddy.service
    '';
  };
}
