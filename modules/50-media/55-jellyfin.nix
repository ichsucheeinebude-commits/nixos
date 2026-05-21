# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-JEL-001"
# title: "Jellyfin Media Server"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [jellyfin, media]
# description: "Jellyfin Media Server module."
# path: "modules/50-media/55-jellyfin.nix"
# provides: [my.media.jellyfin]
# requires: [50-media/53-streaming]
# links:
#   adr: docs/adr/ADR-50-jellyfin.md
#   guide: docs/guides/50-jellyfin.md
#   module: modules/50-media/55-jellyfin.nix
# ---
# ---ENDNIXMETA

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
# nms_id: APP-MEDIA-JELLYFIN
# title: Jellyfin (hardened)
# capabilities: [ "media", "jellyfin", "gpu" ]
# status: "hardened"
# tier_strategy: "ABC-v5.1"
# ---
{ lib, pkgs, config, myLib, ... }:
let
 # 🚀 NMS v4.2 Metadaten (hardened Jellyfin)
 # Fragment-Sourcing:
 # - NIXH-40-MED-007: Basis Jellyfin Modul
 # - Fragment 2272: i915 QuickSync GuC/HuC Aktivierung
 # - ADR 852: ABC-Tiering (State Tier A, Cache Tier B)

 cfg = config.my.media.jellyfin;
 srePaths = config.my.configs.paths;
 ssdMetadataDir = "${srePaths.tierB}/metadata/jellyfin";
 
 # Spezifische Kodierungs-Config (hardened Defaults)
 encodingXml = pkgs.writeText "encoding.xml" ''
 <?xml version="1.0" encoding="utf-8"?>
 <EncodingOptions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
 <EncodingThreadCount>-1</EncodingThreadCount>
 <TranscodingTempPath>${srePaths.tierB}/cache/jellyfin-transcode</TranscodingTempPath>
 <EnableHardwareAcceleration>true</EnableHardwareAcceleration>
 <HardwareAccelerationType>qsv</HardwareAccelerationType>
 </EncodingOptions>
 '';

in
{
 options.my.meta.jellyfin = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 };

 options.my.media.jellyfin.enable = lib.mkEnableOption "Jellyfin Media Server";

 config = lib.mkIf cfg.enable (lib.mkMerge [
 
 # 🎬 1. hardened STREAMER FABRIK (Updated Spec)
 # anchor: jellyfin-resource-priority
 (myLib.mkStreamer {
 inherit config;
 name = "jellyfin";
 netns = "media-ns";
 port = config.my.ports.jellyfin;
 useGPU = true; # 🔥 QuickSync / UHD 630 Zugriff
 memoryMax = "4G";
 cpuWeight = 80;
 description = "Jellyfin hardened Instance";
 extraServiceConfig = {
   # CPU Pinning (aktivieren bei Bedarf):
   # CPUAffinity = 2 3;  # Dedizierte Cores für QuickSync, nur bei Performance-Problemen aktivieren
 };
 })

 # 🔧 2. JELLYFIN SPECIFICS
 {
 services.jellyfin = {
 enable = true;
 group = "media";
 };

 # 📅 JELLYFIN SCAN SCHEDULE (anchor: jellyfin-scan)
 # Note: ScanSchedule is not natively exposed in the NixOS module.
 # Set to "0 2 * * *" (02:00 AM) in the Jellyfin Web UI or directly in the XML config.
 # This aligns with the nightly maintenance window and reduces daytime HDD spin-ups.
 # Source: https://jellyfin.org/docs/general/administration/configuration/#scan-schedule

 # 🚀 RAM-DISK FÜR TRANSCODING (anchor: jellyfin-transcode)
 systemd.mounts = [
 {
 where = "/run/jellyfin-transcode";
 what = "tmpfs";
 fsType = "tmpfs";
 options = "size=2G,mode=750,uid=jellyfin,gid=media";
 wantedBy = [ "jellyfin.service" ];
 before = [ "jellyfin.service" ];
 }
 ];

 systemd.services.jellyfin = {
 # QuickSync Treiber-Kontext (Source: Fragment 2272)
 environment = {
 OCL_ICD_VENDORS = "intel";
 LIBVA_DRIVER_NAME = "iHD"; # Force modern Intel Driver
 FFMPEG_TRANSCODING_TEMP_DIR = "/run/jellyfin-transcode";
 };

        serviceConfig = {
          RuntimeDirectory = "jellyfin-transcode";
          RuntimeDirectoryMode = "0750";
          # Netzwerk-Schild (Ergänzend zur Factory)
          IPAddressAllow = [ "127.0.0.1/8" "::1/128" ] 
            ++ config.my.configs.network.lanCidrs;
        };
      };
    }
  ]);
}

