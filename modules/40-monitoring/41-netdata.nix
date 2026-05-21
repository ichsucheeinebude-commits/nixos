# ---NIXMETA
# ---
# domain: 40
# id: "NIXH-40-NTD-001"
# title: "Netdata Metrics"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [netdata, metrics]
# description: "Netdata Metrics module."
# path: "modules/40-monitoring/41-netdata.nix"
# provides: [my.monitoring.netdata]
# requires: [40-monitoring/40-gatus]
# links:
#   adr: docs/adr/ADR-40-netdata.md
#   guide: docs/guides/40-netdata.md
#   module: modules/40-monitoring/41-netdata.nix
# ---
# ---ENDNIXMETA

# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-080-MON-NET-001",
#   "title": "Netdata Real-time Telemetry",
#   "layer": 80,
#   "category": "services/monitoring",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["monitoring", "netdata", "telemetry", "real-time"],
#   "description": "Hardened Netdata configuration with socket-only access and dbengine storage."
# }
# ---ENDNIXMETA

{ config, lib, ... }:
let
 
 port = config.my.ports.netdata;
 domain = config.my.configs.identity.domain;
in
{
 options.my.meta.netdata = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 description = "NMS metadata for netdata module";
 };


  config = lib.mkIf config.my.services.netdata.enable {
    # 📈 NETDATA TELEMETRY (anchor: netdata-telemetry)
    services.netdata = {
      enable = true;
      config = {
        global = { "memory mode" = "dbengine"; "page cache size" = "256"; "dbengine disk space" = "4096"; "history" = 86400; };
        web = { 
          "bind to" = "unix:/run/netdata/netdata.sock";
          "allow connections from" = "localhost 127.0.0.1"; # Keep for internal health checks if any
          "mode" = "static-threaded"; 
        };
        db = { "dbengine tier 1 retention days" = 30; };
        health.enabled = "yes";
      };
    };

    systemd.services.netdata.serviceConfig = {
      ProtectSystem = lib.mkForce "full"; 
      ProtectHome = lib.mkForce true; 
      PrivateTmp = lib.mkForce true; 
      PrivateDevices = lib.mkForce true;
      NoNewPrivileges = true; 
      CapabilityBoundingSet = [ "CAP_DAC_READ_SEARCH" "CAP_SYS_PTRACE" "CAP_NET_RAW" ]; 
      AmbientCapabilities = [ "CAP_DAC_READ_SEARCH" "CAP_SYS_PTRACE" "CAP_NET_RAW" ];
      MemoryMax = "1G"; 
      CPUWeight = 50; 
      OOMScoreAdjust = 1000;
      # Allow socket access
      RuntimeDirectory = "netdata";
      RuntimeDirectoryMode = "0770";
    };

    # Update Caddy to use the unix socket
    services.caddy.virtualHosts."netdata.${config.my.configs.identity.subdomain}.${domain}".extraConfig = lib.mkForce ''
      import admin_auth
      import hardened_headers
      reverse_proxy unix//run/netdata/netdata.sock
    '';
  };
}
