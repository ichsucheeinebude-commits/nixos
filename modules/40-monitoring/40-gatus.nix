# ---NIXMETA
# ---
# domain: 40
# id: "NIXH-40-GAT-001"
# title: "Gatus Health Checks"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [gatus, monitoring]
# description: "Gatus Health Checks module."
# path: "modules/40-monitoring/40-gatus.nix"
# provides: [my.monitoring.gatus]
# requires: [10-network/10-network]
# links:
#   adr: docs/adr/ADR-40-gatus.md
#   guide: docs/guides/40-gatus.md
#   module: modules/40-monitoring/40-gatus.nix
# ---
# ---ENDNIXMETA

# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-090-MON-GAT-001",
#   "title": "Gatus Health Dashboard",
#   "layer": 90,
#   "category": "services/monitoring",
#   "lastReviewed": "2026-05-14",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 3,
#   "tags": ["monitoring", "gatus", "healthcheck"],
#   "description": "Hardened health dashboard with socket-first monitoring and ntfy alerting."
# }
# ---ENDNIXMETA

# Dashboard accessible ONLY via WireGuard tunnel (admin_auth).
{ config, lib, pkgs, myLib, ... }:

let
 cfg = config.my.monitoring.gatus;
 srePaths = config.my.configs.paths;
 identity = config.my.configs.identity;
 
 # 🚀 GATUS CONFIG GENERATOR
 gatusConfig = let
 # Use identity to resolve public domain for alerting click-throughs
 publicUrl = "https://gatus.${identity.subdomain}.${identity.domain}";
 
 yamlStruct = {
 storage = {
 type = "sqlite";
 path = "${srePaths.stateDir}/gatus/data.db";
 };
      web = {
        port = cfg.port;
        address = "127.0.0.1";
      };
      endpoints = cfg.endpoints ++ [
 { 
 name = "Gatus Self"; 
 url = "unix:///run/gatus/gatus.sock:/api/v1/health"; 
 interval = "60s"; 
 conditions = [ "[STATUS] == 200" ]; 
 }
 ];
 } // (lib.optionalAttrs cfg.ntfy.enable {
 alerting = {
 ntfy = {
 inherit (cfg.ntfy) url topic priority;
 click = publicUrl;
 };
 };
 });
 in pkgs.writeText "gatus.yaml" (builtins.toJSON yamlStruct);

in {
 options.my.monitoring.gatus = {
 enable = lib.mkEnableOption "Gatus Health Dashboard";
 port = lib.mkOption { type = lib.types.port; default = config.my.ports.gatus; };
 
 # 🔥 NTFY ALERTING (ADR 882)
 ntfy = lib.mkOption {
 type = lib.types.submodule {
 options = {
 enable = lib.mkEnableOption "ntfy alerting";
 url = lib.mkOption { 
 type = lib.types.str; 
 default = identity.ntfyUrl; 
 description = "ntfy server URL (Default: Local)";
 };
 topic = lib.mkOption { 
 type = lib.types.str; 
 default = "gatus-alerts"; 
 description = "ntfy topic";
 };
 priority = lib.mkOption { 
 type = lib.types.int; 
 default = 3; 
 description = "ntfy priority (1-5)";
 };
 };
 };
 default = {};
 };

 # 🔍 HEALTH ENDPOINTS (anchor: health-endpoints)
 endpoints = lib.mkOption {
 type = lib.types.listOf lib.types.attrs;
 default = [
 { 
 name = "Caddy Local"; 
 url = "unix:///run/caddy/admin.sock:/config/"; 
 interval = "60s"; 
 conditions = [ "[STATUS] == 200" ]; 
 }
 { 
 name = "Jellyfin"; 
 url = "unix:///run/jellyfin/jellyfin.sock:/health"; 
 interval = "60s"; 
 conditions = [ "[STATUS] == 200" ]; 
 }
 { 
 name = "Navidrome"; 
 url = "unix:///run/navidrome/navidrome.sock:/rest/ping.view"; 
 interval = "60s"; 
 conditions = [ "[STATUS] == 200" ]; 
 }
 { 
 name = "Pocket-ID"; 
 url = "unix:///run/pocket-id/pocket-id.sock:/health"; 
 interval = "60s"; 
 conditions = [ "[STATUS] == 200" ]; 
 }
 { 
 name = "PostgreSQL"; 
 url = "unix:///run/postgresql/.s.PGSQL.5432"; 
 interval = "60s"; 
 conditions = [ "[CONNECTED] == true" ]; 
 }
 { 
 name = "Valkey"; 
 url = "unix:///run/valkey/valkey.sock"; 
 interval = "60s"; 
 conditions = [ "[CONNECTED] == true" ]; 
 }
 { 
 name = "Blocky DNS"; 
 # ⚠️ EXCEPTION: Blocky does not support unix sockets for metrics (Audit Topic 6)
 url = "http://127.0.0.1:4000/metrics"; 
 interval = "60s"; 
 conditions = [ "[STATUS] == 200" ]; 
 }
 ];
 description = "List of endpoints to monitor (declarative).";
 };
 };

 config = lib.mkIf cfg.enable (lib.mkMerge [
 # 🎬 1. hardened SERVICE FABRIK
 (myLib.mkService {
 inherit config;
 name = "gatus";
 port = cfg.port;
 # Dashboard accessible ONLY via WireGuard tunnel
useSSO = false;
 persist = true;
 description = "Gatus Health Dashboard";
     extraServiceConfig = {
        ExecStart = lib.mkForce "${pkgs.gatus}/bin/gatus --config \"${gatusConfig}\"";
        # 🌐 NETWORK ACCESS (v6.1 Hardening Override for Alerting)
        IPAddressAllow = "any";
      };
 })

 # 🔧 2. GATUS SPECIFICS
 {
 # Permissions for the state directory
 systemd.tmpfiles.rules = [
 "d ${srePaths.stateDir}/gatus 0750 gatus gatus -"
 ];
 }
 ]);
}
