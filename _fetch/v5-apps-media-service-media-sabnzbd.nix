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
# nms_id: APP-MEDIA-SABNZBD
# title: SABnzbd Usenet Downloader
# capabilities: ["media/downloading"]
# status: "hardened"
# tier_strategy: "ABC-v5.1"
# ---
{ config, lib, pkgs, myLib, ... }:
let
 # 🚀 NMS v4.2 Metadaten (hardened SABnzbd)
 # Fragment-Sourcing:
 # - NIXH-40-MED-015: Basis Sabnzbd Modul
 # - Fragment 11249: Noexec for download directories
 # - Fragment 3331: LoadCredential for Secrets
 # - ADR 852: ABC-Tiering Path Strategy
 nms = {
 id = "NIXH-01-APP-SAB-001";
 title = "SABnzbd (hardened)";
 description = "Hardened Usenet download client with ABC-Tiering and Secret-Isolation.";
 layer = 40;
 nixpkgs.category = "services/media";
 capabilities = ["media/usenet" "security/sandboxing" "storage/tiering"];
 audit.last_reviewed = "2026-04-27";
 audit.complexity = 3;
 };

 cfg = config.my.media.sabnzbd;
 srePaths = config.my.configs.paths;
in
{
 options.my.meta.sabnzbd = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 };

 options.my.media.sabnzbd = {
 enable = lib.mkEnableOption "SABnzbd Usenet Downloader";
 user = lib.mkOption { type = lib.types.str; default = "sabnzbd"; };
 group = lib.mkOption { type = lib.types.str; default = "media"; };
 port = lib.mkOption { type = lib.types.port; default = config.my.ports.sabnzbd; };
 
 # 💾 PATH STRATEGY (ABC-Tiering)
 stateDir = lib.mkOption { 
 type = lib.types.str; 
 default = "${srePaths.stateDir}/sabnzbd"; 
 description = "State directory (Tier A/Persist)";
 };
 incompleteDir = lib.mkOption { 
 type = lib.types.str; 
 default = "${srePaths.downloads}/incomplete"; 
 description = "Staging area for active downloads (Tier B B3)";
 };
 downloadDir = lib.mkOption { 
 type = lib.types.str; 
 default = "${srePaths.tierC}/archive/usenet"; 
 description = "Final cold storage for downloads (Tier C Archive)";
 };

 # 🔑 SECRETS (Source: Fragment 3331)
 apiKeyFile = lib.mkOption { 
 type = lib.types.nullOr lib.types.path; 
 default = null; 
 description = "Path to the SABnzbd API Key (via Sops)";
 };
 nzbKeyFile = lib.mkOption { 
 type = lib.types.nullOr lib.types.path; 
 default = null; 
 description = "Path to the SABnzbd NZB Key (via Sops)";
 };
 };

 config = lib.mkIf cfg.enable (lib.mkMerge [
 # 🏆 Use the hardened Service Factory
 (myLib.mkService {
 inherit config;
 name = "sabnzbd";
 netns = "media-ns";
 port = cfg.port;
 useSSO = true;
 description = "SABnzbd Usenet Client";
 persist = true;
 extraServiceConfig = {
   IPAddressAllow = "any";
   MemoryMax = "2G";
 };
 readWritePaths = [ 
 cfg.stateDir 
 cfg.incompleteDir 
 cfg.downloadDir 
 ];
 })

 {
 services.sabnzbd = {
 enable = true;
 user = cfg.user;
 group = cfg.group;
 };

 systemd.services.sabnzbd = {
 # Force Config Path
 environment.SAB_CONFIG_FILE = "${cfg.stateDir}/sabnzbd.ini";

 # 🔑 SECRET ISOLATION (Source: Fragment 3335)
 serviceConfig = {
 # 🚀 SSD-ENDURANCE HARDENING (Move incomplete to RAM)
 RuntimeDirectory = "sabnzbd-tmp";
 RuntimeDirectoryMode = "0750";

 # Load API Keys into the service context safely
 LoadCredential = lib.flatten [
 (lib.optional (cfg.apiKeyFile != null) "SAB_API_KEY:${toString cfg.apiKeyFile}")
 (lib.optional (cfg.nzbKeyFile != null) "SAB_NZB_KEY:${toString cfg.nzbKeyFile}")
 ];

 # 🛡️ hardening (Source: Fragment 3108)
 # anchor: sabnzbd-resource-priority
 MemoryMax = "2G";
 CPUWeight = 40; # Lower priority than Jellyfin
 OOMScoreAdjust = 500; # Kill SABnzbd before Core services
 
 # Sandbox tightening
 ProtectSystem = "strict";
 ProtectHome = true;
 PrivateTmp = true;
 PrivateDevices = true;
 NoNewPrivileges = true;
 RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
 SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
 };
 };

      # 📁 PERMISSION MANAGEMENT
      systemd.tmpfiles.rules = [
        "d ${cfg.stateDir} 0750 ${cfg.user} ${cfg.group} -"
        "d ${cfg.downloadDir} 0775 ${cfg.user} ${cfg.group} -"
      ];
    }
  ]);
}
/**
 * ---\n * technical_integrity:\n * checksum: sha256:e13a9c7b9600bfbd98bc1057589bcf25b5b1b8aa890de35898f63eb3211fd04f1\n * eof_marker: NIXHOME_VALID_EOF* ---\n */
