# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-INF-006"
# title: "Valkey (SRE Exhausted)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [valkey,redis,cache,sandboxing,memory-cap]
# description: "Valkey (Redis fork) with memory caps, aviation-grade sandboxing."
# path: "modules/20-security/24-valkey.nix"
# provides: [my.infrastructure.valkey]
# requires: [00-core]
# links:
#   module: modules/20-security/24-valkey.nix
# source: _meta/20-infrastructure/valkey.nix (NIXH-20-INF-006)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
  cfg = config.my.infrastructure.valkey;
in
{
  options.my.infrastructure.valkey = {
    enable = lib.mkEnableOption "Valkey (Redis fork) cache";
    bind = lib.mkOption { type = lib.types.str; default = "127.0.0.1"; };
    port = lib.mkOption { type = lib.types.port; default = 6379; };
    maxmemory = lib.mkOption { type = lib.types.str; default = "512mb"; };
    maxmemoryPolicy = lib.mkOption { type = lib.types.str; default = "allkeys-lru"; };
    unixSocket = lib.mkOption { type = lib.types.str; default = "/run/redis-valkey/redis.sock"; };
  };

  config = lib.mkIf cfg.enable {
    services.redis.package = pkgs.valkey;
    services.redis.servers.valkey = {
      enable = true;
      bind = cfg.bind;
      port = cfg.port;
      openFirewall = false;
      settings = {
        maxmemory = cfg.maxmemory;
        maxmemory-policy = cfg.maxmemoryPolicy;
        save = [ "900 1" "300 10" "60 10000" ];
        unixsocket = cfg.unixSocket;
        unixsocketperm = lib.mkForce "770";
      };
    };

    systemd.services.redis-valkey.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      NoNewPrivileges = true;
      MemoryDenyWriteExecute = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_UNIX" ];
      OOMScoreAdjust = -500;
    };
  };
}
