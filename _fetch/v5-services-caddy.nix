# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-010-SRV-GTW-001",
#   "title": "Caddy Hardened Gateway",
#   "layer": 10,
#   "category": "services/gateway",
#   "lastReviewed": "2026-05-14",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 4,
#   "tags": ["caddy", "ingress", "sso", "security"],
#   "description": "Hardened Edge Proxy with GeoIP, SSO, Stealth 444 response, and rate-limiting."
# }
# ---ENDNIXMETA
{ config, lib, pkgs, myLib, ... }:
let
  cfg = config.my.services.caddy;
  sreConfig = config.my.configs;
  
  # 🌐 Trusted IPs (LAN only - Cloudflare proxying is disabled)
  # Source: Fragment 18278 & Local Network SSoT
  trustedIPs = lib.concatStringsSep " " (
    [ "127.0.0.1" "::1" ]
    ++ sreConfig.network.lanCidrs
  );

in {
  options.my.services.caddy = {
    enable = lib.mkEnableOption "Caddy Edge Proxy";
  };

 config = lib.mkIf config.my.services.caddy.enable {
 
 # 🏎️ KERNEL TUNING (Source: Fragment 18265)
 boot.kernel.sysctl = {
 "net.core.rmem_max" = 8388608;
 "net.core.wmem_max" = 8388608;
 "net.ipv4.tcp_fastopen" = 3;
 };

    services.caddy = {
      enable = true;
      
      # 🛠️ GLOBAL OPTIONS (Source: Fragment 2526 / Performance Kick)
      # 🛡️ CADDY HARDENING (anchor: caddy-hardening)
      globalConfig = ''
      admin unix//run/caddy/admin.sock

      # 🧩 Order of custom modules
      order rate_limit before basicauth

      # 🧩 Performance & Resources
      servers {
        trusted_proxies static ${trustedIPs}
        trusted_proxies_strict
        # Speed-up: Buffer settings
        max_header_size 16kb
      }

      # 📊 Structured Logging for fail2ban
      log {
        output file /var/log/caddy/access.log {
          roll_size 10MB
          roll_keep 3
          roll_keep_for 7d
        }
        format json
      }

      # 🔄 DYNAMIC DNS (Source: Caddy-on-Steroids)
      dynamic_dns {
        provider cloudflare {env.CLOUDFLARE_API_TOKEN}
        domains {
          ${sreConfig.identity.domain} @
          ${sreConfig.identity.subdomain}.${sreConfig.identity.domain} *
        }
        check_interval 5m
      }

      # --- HONEYPOT (Time & Resource Stealer) ---
      (honeypot) {
      @evil_paths {
      not remote_ip private_ranges
      path /.env* /.git* /.vscode* /wp-config* /config.json* /actuator* /phpmyadmin* /.aws* /.ssh* /xmlrpc.php /wp-login* /admin* /setup.php /install.php /shell* /cmd.php /cgi-bin*
      }
      handle @evil_paths {
      # 💀 Connection-Killer: Immediate 444 (No Response)
      header -Server
      log {
      level error
      }
      abort
      }
      }

      # --- RATE LIMITING (Bot Mitigation) ---
      (rate_limit_policy) {
        rate_limit {
          zone auth_limit {
            key {remote_ip}
            events 10
            window 1m
          }
        }
      }

      # --- HARDENED HEADERS (v7.0 Strict Stealth) ---

        (hardened_headers) {
          header {
            X-Content-Type-Options nosniff
            X-Frame-Options DENY
            Referrer-Policy no-referrer-when-downgrade
            Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
            Permissions-Policy interest-cohort=()
            Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self';"
            -Server
          }
        }

        # --- ADMIN AUTH (LAN-only Hangar) ---
        (admin_auth) {
          @admin_hangar {
            remote_ip private_ranges
          }
          handle @admin_hangar {
            import hardened_headers
            import compression
            # reverse_proxy is added in the vhost generation
          }
          respond "Forbidden: Admin access restricted to LAN" 403
        }

        # --- FAMILY AUTH (Pocket-ID) (anchor: family-auth)
        # 🛡️ FORWARD-AUTH (anchor: forward-auth)
        (family_auth) {
          import rate_limit_policy
          @needs_auth {
            not remote_ip 127.0.0.1
            not header_regexp host ^auth\.
            not path /.well-known/*
          }
          # FW-NEW-01 FIX: Fallback to TCP listener for Pocket-ID (anchor: forward-auth)
          forward_auth @needs_auth 127.0.0.1:${toString config.my.ports."pocket-id" or 8089} {
            uri /api/auth/verify
            copy_headers X-Forwarded-User
          }
          import hardened_headers
          import honeypot
          import compression
        }

        # --- ACME CHALLENGE BYPASS ---
        (acme_bypass) {
          handle /.well-known/acme-challenge/* {
            root * /var/lib/caddy/acme-challenges
            file_server
          }
        }
      '';
    };

    # 🛡️ SYSTEMD SANDBOXING (gehärtet / Source: Fragment 2833)
    users.users.caddy.uid = config.my.users.registry.caddy;
    systemd.services.caddy = {
      # Source: Fragment 18333
      serviceConfig = {
        EnvironmentFile = [config.sops.templates."caddy-env".path];
        
        # Holy State Persistence
        StateDirectory = "caddy"; 
        RuntimeDirectory = "caddy";
        RuntimeDirectoryMode = "0750";
        ReadWritePaths = [ "/var/lib/caddy" "/var/log/caddy" ];
        
        # Hardening Shield
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        MemoryDenyWriteExecute = true;
        OOMScoreAdjust = -900;
        
        # Hide Process Info (ProtectProc)
        ProcSubset = "pid";
        ProtectProc = "invisible";
        
        # 🌐 NETWORK ACCESS (v6.1 Hardening Override)
        IPAddressAllow = "any";

        # Grant low-port binding capability
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        };

        restartTriggers = [
        config.sops.templates."caddy-env".path
        config.services.caddy.globalConfig
        ];
        };


    # 🚀 AUTOMATED VHOST GENERATION (from services-spec.nix)
    services.caddy.virtualHosts = let
      cfgSpec = config.my.services.spec;
      identity = config.my.configs.identity;
      
      # Helper to build the FQDN
      mkFQDN = svc: "${svc.domain}.${identity.subdomain}.${identity.domain}";
      
      # Helper to build the upstream address (Socket > IP:Port)
      mkUpstream = name: svc: if svc.socket != null 
        then "unix/${svc.socket}" 
        else if svc.zone == config.my.configs.zones.admin
        then "127.0.0.2:${toString svc.port}"
        else "127.0.0.1:${toString svc.port}";

      # Filter for services that need an ingress proxy
      ingressServices = lib.filterAttrs (_: svc: svc.domain != null) cfgSpec;
      
      # Generate virtual host config per service
      genVHost = name: svc: {
        name = mkFQDN svc;
        value = {
          extraConfig = if svc.domain == "auth" then ''
              import acme_bypass
              # Public endpoints for OIDC/Auth
              handle /api/auth/* {
                reverse_proxy ${mkUpstream name svc}
              }
              handle /.well-known/* {
                reverse_proxy ${mkUpstream name svc}
              }
              # Administrative paths restricted to LAN
              handle /admin/* {
                import admin_auth
                reverse_proxy ${mkUpstream name svc}
              }
              # Fallback to family_auth for everything else
              handle {
                import family_auth
                reverse_proxy ${mkUpstream name svc}
              }
            ''
            else if svc.zone == config.my.configs.zones.admin then ''
              import acme_bypass
              import admin_auth
              reverse_proxy ${mkUpstream name svc}
            ''
            else if svc.zone == config.my.configs.zones.public then ''
              import acme_bypass
              import hardened_headers
              reverse_proxy ${mkUpstream name svc}
            ''
            else ''
              import acme_bypass
              import family_auth
              ${if svc.domain == "media" || svc.domain == "music" || svc.domain == "audiobooks" then 
                "import proxy_stream ${mkUpstream name svc}" 
                else "reverse_proxy ${mkUpstream name svc}"}
            '';
        };
      };
      
      baseHosts = lib.listToAttrs (lib.mapAttrsToList genVHost ingressServices);
      
      # 🛡️ CATCH-ALL WILDCARD
      catchAllHost = {
        "*.${identity.subdomain}.${identity.domain}" = {
          extraConfig = ''
            import acme_bypass
            import honeypot
            import hardened_headers
            abort
          '';
        };
      };
    in lib.recursiveUpdate baseHosts catchAllHost;
  };
}
