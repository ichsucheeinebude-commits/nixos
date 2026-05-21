# ---NIXMETA
# ---
# domain: 40
# id: "NIXH-40-VEC-001"
# title: "Vector Log Pipeline"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [vector, logs]
# description: "Vector Log Pipeline module."
# path: "modules/40-monitoring/44-vector.nix"
# provides: [my.monitoring.vector]
# requires: [40-monitoring/41-netdata]
# links:
#   adr: docs/adr/ADR-40-vector.md
#   guide: docs/guides/40-vector.md
#   module: modules/40-monitoring/44-vector.nix
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let

  cfg = config.my.services.vector;
  u = config.my.users.registry;
in {
  options.my.services.vector.enable = lib.mkEnableOption "Vector Log Aggregator";

  config = lib.mkIf cfg.enable {

    services.vector = {
      enable = true;
      journaldAccess = true;
      
      settings = {
        sources = {
          journal = {
            type = "journald";
          };
        };
        
        sinks = {
          file_output = {
            type = "file";
            path = "/var/log/vector/all-logs-%Y-%m-%d.json";
            inputs = [ "journal" ];
            encoding = { codec = "json"; };
            # Rotation, um die Platte nicht vollaufen zu lassen
            max_size = 104857600; # 100MB
          };
        };
      };
    };

    users.users.vector = {
      isSystemUser = true;
      group = "vector";
      uid = u.vector;
    };
    users.groups.vector = {};

    systemd.services.vector.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      NoNewPrivileges = true;
      RestrictNamespaces = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      CapabilityBoundingSet = [];
      AmbientCapabilities = [];
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
      SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" "~@mount" ];
      ReadWritePaths = [ "/var/log/vector" ];
    };

    # Create target directory for Vector logs
    systemd.tmpfiles.rules = [ "d /var/log/vector 0750 vector vector -" ];
  };
}
