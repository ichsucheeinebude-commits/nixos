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

# ---
# nms_id: APP-MEDIA-ABS
# title: Audiobookshelf (hardened)
# capabilities: [ "audiobooks", "podcasts" ]
# status: "hardened"
# tier_strategy: "ABC-v5.1"
# ---
{ config, lib, pkgs, myLib, ... }:
let
 # 🚀 NMS v4.2 Metadaten (hardened Audiobookshelf)
 # Fragment-Sourcing:
 # - NIXH-40-MED-002: Vorherige Version
 # - ADR 852: ABC-Tiering Path Strategy
 nms = {
 id = "NIXH-01-APP-ABS-001";
 title = "Audiobookshelf (hardened)";
 description = "Hardened Audiobook & Podcast server with ABC-Tiering and specialized cache.";
 layer = 40;
 nixpkgs.category = "services/media";
 capabilities = ["media/audiobooks" "media/podcasts" "security/sandboxing"];
 audit.last_reviewed = "2026-04-27";
 audit.complexity = 2;
 };

 cfg = config.my.apps.audiobookshelf;
 srePaths = config.my.configs.paths;
 sreConfig = config.my.configs;

in
{
 options.my.meta.audiobookshelf = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 };

 options.my.apps.audiobookshelf = {
 enable = lib.mkEnableOption "Audiobookshelf media server";
 user = lib.mkOption { type = lib.types.str; default = "audiobookshelf"; };
 group = lib.mkOption { type = lib.types.str; default = "media"; };
 port = lib.mkOption { type = lib.types.port; default = config.my.ports.audiobookshelf or 8000; }; 
 # 💾 PATH STRATEGY (ABC-Tiering)
 stateDir = lib.mkOption { 
 type = lib.types.str; 
 default = "${srePaths.stateDir}/audiobookshelf"; 
 description = "Database and metadata (Tier A/Persist)";
 };
 # 📚 AUDIOBOOK LIBRARY (anchor: abs-library)
 audiobookDir = lib.mkOption {
 type = lib.types.str;
 default = "${srePaths.mediaLibrary}/audiobooks";
 description = "Audiobook library (Tier C)";
 };
 podcastDir = lib.mkOption {
 type = lib.types.str;
 default = "${srePaths.mediaLibrary}/podcasts";
 description = "Podcast library (Tier C)";
 };
 };

 config = lib.mkIf cfg.enable (lib.mkMerge [
 
 # 🎬 1. hardened STREAMER FABRIK
 (myLib.mkStreamer {
 inherit config;
 name = "audiobookshelf";
 netns = "media-ns";
 port = cfg.port;
 useGPU = false; # Audiobookshelf uses CPU for transcoding
 memoryMax = "2G";
 cpuWeight = 70;
 oomScoreAdjust = 350;
 description = "Audiobookshelf Instance";
 extraServiceConfig = {
   # CPU Pinning (aktivieren bei Bedarf):
   # CPUAffinity = 2 3;  # Dedizierte Cores für QuickSync, nur bei Performance-Problemen aktivieren
 };
 })

 {
 # Caddy Subdomain Override (hardened Identity)
 services.caddy.virtualHosts."abs.${sreConfig.identity.subdomain}.${sreConfig.identity.domain}" = 
 config.services.caddy.virtualHosts."audiobookshelf.${sreConfig.identity.subdomain}.${sreConfig.identity.domain}";

 services.audiobookshelf = {
 enable = true;
 user = cfg.user;
 group = cfg.group;
 dataDir = cfg.stateDir;
 port = cfg.port;
 host = "127.0.0.1";
 };

 systemd.services.audiobookshelf = {
 # 🔗 NODE.JS HARDENING (Audiobookshelf is Node.js based)
 serviceConfig = {
 # Path Management (SRE-Standard)
 ReadWritePaths = [
 cfg.stateDir
 cfg.audiobookDir
 cfg.podcastDir
 ];
 
 # Node.js JIT Exception (Source: Fragment 9654)
 MemoryDenyWriteExecute = false; 
 };

 restartTriggers = [
   config.services.audiobookshelf.package
 ];
 };
 };

      # 📁 PERMISSION MANAGEMENT
      systemd.tmpfiles.rules = [
        "d ${cfg.stateDir} 0750 ${cfg.user} ${cfg.group} -"
        "d ${cfg.audiobookDir} 0775 ${cfg.user} ${cfg.group} -"
        "d ${cfg.podcastDir} 0775 ${cfg.user} ${cfg.group} -"
      ];
    }
  ]);
}
/**
 * ---\n * technical_integrity:\n * checksum: sha256:d13e9a7b9600bfbd98bc1057589bcf25b5b1b8aa890de35898f63eb3211fd04f11\n * eof_marker: NIXHOME_VALID_EOF* ---\n */
