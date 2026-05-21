{
  config,
  pkgs,
  lib,
  ...
}: let
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-00-COR-010";
    title = "Fail2ban (SRE Aggressive)";
    description = "Aggressive brute-force protection with specialized Caddy JSON filters and incremental banning.";
    layer = 00;
    nixpkgs.category = "services/security";
    capabilities = ["security/bruteforce-protection" "network/hardening"];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 2;
  };

  sshPort = toString config.my.ports.ssh;
  lanCidrs = config.my.configs.network.lanCidrs;
  tailnetCidrs = config.my.configs.network.tailnetCidrs;
in {
  options.my.meta.fail2ban = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  config = lib.mkIf (config.my.services.fail2ban.enable or true) {
    services.fail2ban = {
      enable = true;
      # 🛡️ GLOBAL HARDENING
      banaction = "nftables-multiport";
      banaction-allports = "nftables-allports";
      ignoreIP = ["127.0.0.1/8" "::1"] ++ lanCidrs ++ tailnetCidrs;

      bantime = "1h";
      maxretry = 5;

      # 📈 INCREMENTAL BANNING (Nixpkgs Native)
      bantime-increment = {
        enable = true;
        multipliers = "1 2 4 8 16 32 64";
        maxtime = "168h"; # 1 Woche max
      };

      daemonSettings.Definition.logtarget = "SYSLOG";

      jails = {
        sshd.settings = {
          enabled = true;
          port = sshPort;
          mode = "aggressive";
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

    # 🔍 CUSTOM FILTERS
    environment.etc = {
      "fail2ban/filter.d/caddy-json.conf".text = ''
        [Definition]
        failregex = ^.*"remote_ip":"<ADDR>".*"status":(401|403).*$
        journalmatch = _SYSTEMD_UNIT=caddy.service
      '';
      "fail2ban/filter.d/caddy-scan.conf".text = ''
        [Definition]
        failregex = ^.*"remote_ip":"<ADDR>".*"uri":".*(?:/\.git|/\.env|/wp-admin|/wp-login\.php|/xmlrpc\.php)".*"status":404.*$
        journalmatch = _SYSTEMD_UNIT=caddy.service
      '';
    };

    # 🛡️ SYSTEMD SANDBOXING
    systemd.services.fail2ban.serviceConfig = {
      OOMScoreAdjust = 500;
      ProtectSystem = "strict";
      ReadWritePaths = ["/var/lib/fail2ban" "/var/run/fail2ban"];
      PrivateTmp = true;
    };
  };
}
/**
* ---
 * technical_integrity:
 *   checksum: sha256:5c444a82f277d479743d034c4cf03aa8819b05d9f9044d87daacb54ac8ba3368
 *   eof_marker: NIXHOME_VALID_EOF* ---
*/

