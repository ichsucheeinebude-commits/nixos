# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-005"
# title: "Matrix Conduit (SRE Hardened)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [matrix,conduit,homeserver,chat,sandboxing]
# description: "Lightweight Matrix homeserver (Conduit/Rust) with strict sandboxing."
# path: "modules/60-apps/64-matrix-conduit.nix"
# provides: [my.apps.matrixConduit]
# requires: [10-network, 20-security]
# links:
#   module: modules/60-apps/64-matrix-conduit.nix
# source: _meta/60-apps/service-app-matrix-conduit.nix (NIXH-60-APP-005)
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.apps.matrixConduit;
  port = config.my.ports.matrix or 20006;
  domain = config.my.configs.identity.domain or "m7c5.de";
  subdomain = config.my.configs.identity.subdomain or "nix";
  serverName = "matrix.${subdomain}.${domain}";
in
{
  options.my.apps.matrixConduit = {
    enable = lib.mkEnableOption "Matrix Conduit homeserver";
    allowRegistration = lib.mkOption { type = lib.types.bool; default = true; };
    databaseBackend = lib.mkOption {
      type = lib.types.enum [ "rocksdb" "sqlite" ];
      default = "rocksdb";
    };
    cpuWeight = lib.mkOption { type = lib.types.int; default = 50; };
    memoryMax = lib.mkOption { type = lib.types.str; default = "1G"; };
  };

  config = lib.mkIf cfg.enable {
    services.matrix-conduit = {
      enable = true;
      settings.global = {
        server_name = serverName;
        port = port;
        address = "127.0.0.1";
        database_backend = cfg.databaseBackend;
        allow_registration = cfg.allowRegistration;
      };
    };

    services.caddy.virtualHosts."${serverName}" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:${toString port}
        handle /.well-known/matrix/server {
          respond "{\"m.server\": \"${serverName}:${toString port}\"}" 200
        }
        handle /.well-known/matrix/client {
          respond "{\"m.homeserver\": {\"base_url\": \"https://${serverName}\"}}" 200
        }
      '';
    };

    systemd.services.conduit.serviceConfig = {
      StateDirectory = lib.mkForce "matrix-conduit";
      ReadWritePaths = lib.mkForce [ "/var/lib/matrix-conduit" ];
      MemoryDenyWriteExecute = lib.mkForce false;
      CPUWeight = lib.mkForce cfg.cpuWeight;
      MemoryMax = lib.mkForce cfg.memoryMax;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };
}
