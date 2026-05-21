# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-010-SRV-DNS-001",
#   "title": "Blocky DNS Resolver",
#   "layer": 10,
#   "category": "services/dns",
#   "lastReviewed": "2026-05-14",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["dns", "ad-block", "privacy"],
#   "description": "Hardened DNS resolver with ad-blocking and split-horizon support."
# }
# ---ENDNIXMETA
{ config, lib, pkgs, ... }: 
let
  cfg = config.my.services.blocky;
  lanIP = config.my.configs.network.lanIP;
in {
  options.my.services.blocky = {
    enable = lib.mkEnableOption "Blocky DNS Resolver";
  };

  config = lib.mkIf cfg.enable {
    # 🛡️ BLOCKY DNS (anchor: blocky-dns)
    services.blocky = {
      enable = true;
      settings = {
        ports.dns = 53;
        upstreams.groups.default = [
          "tcp-tls:1.1.1.1:853"
          "tcp-tls:9.9.9.9:853"
        ];
        bootstrapDns = "1.1.1.1";
        
        # 🛡️ Ad-Blocking (anchor: dns-adblocking)
        blocking = {
          blackLists = {
            ads = [
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            ];
          };
          clientGroupsBlock = {
            default = [ "ads" ];
          };
          # Conservative allowlist
          whiteLists.ads = [
            "api.thetvdb.com"
            "api.themoviedb.org"
            "api.radarr.video"
          ];
        };

        # 🎯 Split-Horizon
        conditional = {
          mapping = {
            "${config.my.configs.identity.subdomain}.${config.my.configs.identity.domain}" = "127.0.0.1, ::1";
            "${config.my.configs.identity.domain}" = "127.0.0.1, ::1";
          };
        };

        # 📊 Monitoring
        prometheus.enable = true;
        prometheus.path = "/metrics";
      };
    };

    # 👤 Static UID from registry
    users.users.blocky = {
      isSystemUser = true;
      group = "blocky";
      uid = config.my.users.registry.blocky;
    };
    users.groups.blocky = {};

    systemd.services.blocky.serviceConfig = {
      # 🛡️ Hardening (v7.1 Strict)
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      PrivateNetwork = false; # Needs network for DNS
      NoNewPrivileges = true;
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
      SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
      MemoryHigh = "200M";
      MemoryMax = "500M";
    };

    systemd.services.blocky.restartTriggers = [
      (builtins.toJSON config.services.blocky.settings)
    ];

    # Forward local resolver to blocky

    services.resolved.extraConfig = ''
      DNS=127.0.0.1
      Domains=~.
    '';
  };
}
