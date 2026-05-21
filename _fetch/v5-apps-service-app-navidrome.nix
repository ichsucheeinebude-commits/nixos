# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-040-MED-NAV-001",
#   "title": "Navidrome Music Server",
#   "layer": 40,
#   "category": "services/media",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["music", "streaming", "subsonic", "hardened"],
#   "description": "Hardened Navidrome configuration with Subsonic API enabled and ABC-Tiering."
# }
# ---ENDNIXMETA

{ config, lib, pkgs, myLib, ... }:
let
 nms = {
 id = "NIXH-01-APP-NAV-001";
 title = "Navidrome (hardened Music Server)";
 layer = 40;
 audit.last_reviewed = "2026-04-28";
 };
 cfg = config.my.media.navidrome;
 srePaths = config.my.configs.paths;
 sreConfig = config.my.configs;
in
{
 options.my.media.navidrome = {
 enable = lib.mkEnableOption "Navidrome Music Server";
 user = lib.mkOption { type = lib.types.str; default = "navidrome"; };
 group = lib.mkOption { type = lib.types.str; default = "media"; };
 port = lib.mkOption { type = lib.types.port; default = config.my.ports.navidrome or 4533; };
 stateDir = lib.mkOption { type = lib.types.str; default = "${srePaths.stateDir}/navidrome"; };
 cacheDir = lib.mkOption { type = lib.types.str; default = "${srePaths.tierB}/cache/navidrome"; };
 musicDir = lib.mkOption { type = lib.types.str; default = "${srePaths.mediaLibrary}/music"; };
 };

 config = lib.mkIf cfg.enable (lib.mkMerge [
 # 🎬 1. hardened STREAMER FABRIK
 (myLib.mkStreamer {
 inherit config;
 name = "navidrome";
 netns = "media-ns";
 port = cfg.port;
 useGPU = false;
 memoryMax = "1G";
 cpuWeight = 60;
 description = "Navidrome Music Streaming";
 extraServiceConfig = {
   # CPU Pinning (aktivieren bei Bedarf):
   # CPUAffinity = 2 3;  # Dedizierte Cores für QuickSync/Transcoding
 };
 })

 # 🔧 2. NAVIDROME SPECIFICS
 {
 users.users.${cfg.user} = {
 isSystemUser = true;
 group = cfg.group;
 home = cfg.stateDir;
 extraGroups = [ "media" ];
 };

 # 🎵 NAVIDROME STREAMING (anchor: navidrome-streaming)
 services.navidrome = {
 enable = true;
 user = cfg.user;
 group = cfg.group;
 address = "127.0.0.1";
 port = cfg.port;
 musicFolder = cfg.musicDir;
 dataFolder = cfg.stateDir;
 cacheFolder = cfg.cacheDir;
 settings.EnableSubsonicApi = true;
 };

 # 🔗 Caddy Subdomain Override
 services.caddy.virtualHosts."music.${sreConfig.identity.subdomain}.${sreConfig.identity.domain}" =
 config.services.caddy.virtualHosts."navidrome.${sreConfig.identity.subdomain}.${sreConfig.identity.domain}";

 systemd.services.navidrome.serviceConfig.ReadOnlyPaths = [ cfg.musicDir ];

      systemd.tmpfiles.rules = [
        "d ${cfg.stateDir} 0750 ${cfg.user} ${cfg.group} -"
        "d ${cfg.cacheDir} 0750 ${cfg.user} ${cfg.group} -"
      ];
    }
  ]);
}
