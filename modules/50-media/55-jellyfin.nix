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
# ---
# title: Jellyfin (hardened)
# capabilities: [ "media", "jellyfin", "gpu" ]
# status: "hardened"
# tier_strategy: "ABC-v5.1"
# ---
{ lib, pkgs, config, myLib, ... }:
let
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

 options.my.media.jellyfin.enable = lib.mkEnableOption "Jellyfin Media Server";

 config = lib.mkIf cfg.enable (lib.mkMerge [
 
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
 };
 })

 {
 services.jellyfin = {
 enable = true;
 group = "media";
 };

 # Note: ScanSchedule is not natively exposed in the NixOS module.
 # Set to "0 2 * * *" (02:00 AM) in the Jellyfin Web UI or directly in the XML config.
 # This aligns with the nightly maintenance window and reduces daytime HDD spin-ups.
 # Source: https://jellyfin.org/docs/general/administration/configuration/#scan-schedule

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
          IPAddressAllow = [ "127.0.0.1/8" "::1/128" ] 
            ++ config.my.configs.network.lanCidrs;
        };
      };
    }
  ]);
}
