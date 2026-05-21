# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-F2B-001"
# title: "Fail2ban Intrusion Prevention"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [fail2ban, security]
# description: "Fail2ban Intrusion Prevention module."
# path: "modules/20-security/20-fail2ban.nix"
# provides: [my.security.fail2ban]
# requires: [10-network/12-ssh]
# links:
#   adr: docs/adr/ADR-20-fail2ban.md
#   guide: docs/guides/20-fail2ban.md
#   module: modules/20-security/20-fail2ban.nix
# ---
# ---ENDNIXMETA
{
 config,
 pkgs,
 lib,
 ...
}: let

 # SSoT Integration
 sshPort = toString config.my.ports.ssh;
in {
 options.my.services.fail2ban = {
     enable = lib.mkEnableOption "Fail2ban Brute-Force Protection";
   };

   options.my.meta.fail2ban = lib.mkOption {
     type = lib.types.attrs;
     default = nms;
     readOnly = true;
     description = "NMS metadata";
   };

   config = lib.mkIf config.my.services.fail2ban.enable {

 services.fail2ban = {
 enable = true;
 banaction = "nftables-multiport";
 banaction-allports = "nftables-allports";
 
 # Schutz gegen Selbstausschluss (SSoT Configs)
 ignoreIP = [
 "127.0.0.1/8" "::1"
 config.my.configs.network.lanCidr
 ];

 bantime = "1h";
 maxretry = 5;

 bantime-increment = {
 enable = true;
 multipliers = "1 2 4 8 16 32 64";
 maxtime = "168h"; # Max 1 Woche
 };

 jails = {
 sshd.settings = {
 enabled = true;
 port = sshPort;
 mode = "aggressive";
 };

 sshd-rescue.settings = {
 enabled = true;
 port = "2222";
 mode = "aggressive";
 maxretry = 3;
 };
 
 caddy-auth.settings = {
 enabled = true;
 port = "http,https";
 filter = "caddy-json";
 backend = "systemd";
 maxretry = 3;
 findtime = "5m";
 bantime = "24h";
 };

 caddy-scan.settings = {
 enabled = true;
 port = "http,https";
 filter = "caddy-scan";
 backend = "systemd";
 maxretry = 2;
 findtime = "1m";
 bantime = "168h";
 };
 };
 };

 environment.etc = {
 "fail2ban/filter.d/caddy-json.conf".text = ''
 [Definition]
 failregex = ^.*"remote_ip":"<ADDR>".*"status":(401|403).*$
 journalmatch = _SYSTEMD_UNIT=caddy.service
 '';
 "fail2ban/filter.d/caddy-scan.conf".text = ''
 [Definition]
 failregex = ^.*"remote_ip":"<ADDR>".*"uri":".*(?:\.env|\.git|\.config|\.php|\.zip|\.gz|wp-admin|wp-login|xmlrpc)".*"status":(404|444).*$
 journalmatch = _SYSTEMD_UNIT=caddy.service
 '';
 };

 systemd.services.fail2ban.serviceConfig = {
 OOMScoreAdjust = -1000;
 ProtectSystem = "strict";
 ReadWritePaths = ["/var/lib/fail2ban" "/var/run/fail2ban"];
 PrivateTmp = true;
 };
 };
}
