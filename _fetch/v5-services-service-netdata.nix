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
 # 🚀 NMS v4.0 Metadaten
 nms = {
 id = "NIXH-80-MON-002";
 title = "Netdata (SRE Exhausted)";
 description = "Real-time performance monitoring with high-retention dbengine and strict sandboxing.";
 layer = 80;
 nixpkgs.category = "services/monitoring";
 capabilities = [ "monitoring/real-time" "observability/metrics" ];
 audit.last_reviewed = "2026-03-02";
 audit.complexity = 2;
 };

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
