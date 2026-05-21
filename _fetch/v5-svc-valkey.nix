# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-AUTO-GEN",
#   "title": "Auto Generated",
#   "layer": 99,
#   "category": "auto/gen",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["auto-generated"],
#   "description": "Auto-migrated module to NIXMETA 2.0."
# }
# ---ENDNIXMETA

{ pkgs, lib, config, ... }:
let
 # 🚀 NMS v4.0 Metadaten
 nms = {
 id = "NIXH-20-INF-006";
 title = "Valkey (SRE Exhausted)";
 description = "High-performance Valkey (Redis fork) with memory caps and hardened sandboxing.";
 layer = 10;
 nixpkgs.category = "services/databases";
 capabilities = [ "database/key-value" "caching/redis" ];
 audit.last_reviewed = "2026-03-02";
 audit.complexity = 2;
 };
in
{
 options.my.services.valkey.enable = lib.mkEnableOption "Valkey service";
 options.my.meta.valkey = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 description = "NMS metadata for valkey module";
 };


 config = lib.mkIf config.my.services.valkey.enable {
 users.users.redis-valkey.uid = config.my.users.registry.valkey;
 services.redis.package = pkgs.valkey;
 services.redis.servers.valkey = {
 enable = true; 
 bind = "127.0.0.1"; 
 # 🛡️ Socket-First: Disable TCP port
 port = 0; 
 openFirewall = false;
 settings = {
 maxmemory = "512mb"; maxmemory-policy = "allkeys-lru";
 save = [ "900 1" "300 10" "60 10000" ];
 unixsocket = "/run/redis-valkey/redis.sock"; 
 unixsocketperm = lib.mkForce "770";
 };
 };

 # 💾 ABC-Tiering Persistence
 environment.persistence."/persist".directories = [ "/var/lib/redis-valkey" ];

 systemd.services.redis-valkey.serviceConfig = {
   ProtectSystem = "strict"; ProtectHome = true; PrivateTmp = true; PrivateDevices = true; NoNewPrivileges = true;
   RestrictNamespaces = true;
   ProtectKernelLogs = true;
   ProtectControlGroups = true;
   ProtectHostname = true;
   SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" "~@mount" "~@swap" "~@cpu-emulation" ];
   PrivateNetwork = true; PrivateUsers = true;
   MemoryDenyWriteExecute = true; RestrictAddressFamilies = [ "AF_INET" "AF_UNIX" ]; OOMScoreAdjust = -1000;
 };
 systemd.services.redis-valkey.restartTriggers = [
   config.services.redis.package
   (builtins.toJSON config.services.redis.servers.valkey.settings)
 ];
 };
}
