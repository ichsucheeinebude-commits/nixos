# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-INF-001"
# title: "ClamAV (SRE Exhausted)"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [clamav,antivirus,security,scanning]
# description: "Professional antivirus with scheduled scanning and low-priority resource limits."
# path: "modules/20-security/25-clamav.nix"
# provides: [my.infrastructure.clamav]
# requires: []
# links:
#   module: modules/20-security/25-clamav.nix
# source: _meta/20-infrastructure/clamav.nix (NIXH-20-INF-001)
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.infrastructure.clamav;
in
{
  options.my.infrastructure.clamav = {
    enable = lib.mkEnableOption "ClamAV antivirus";
    scanDirectories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "/home" "/var/lib" "/etc" ];
      description = "Directories to scan.";
    };
    excludePaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "^/mnt/media" "^/mnt/fast-pool/downloads" ];
      description = "Regex patterns to exclude from scanning.";
    };
    scanInterval = lib.mkOption {
      type = lib.types.str;
      default = "Sat *-*-* 03:00:00";
      description = "Scanner schedule.";
    };
    maxScanSize = lib.mkOption {
      type = lib.types.str;
      default = "100M";
    };
    maxFileSize = lib.mkOption {
      type = lib.types.str;
      default = "50M";
    };
  };

  config = lib.mkIf cfg.enable {
    services.clamav = {
      daemon.enable = true;
      updater.enable = true;
      scanner = {
        enable = true;
        interval = cfg.scanInterval;
        scanDirectories = cfg.scanDirectories;
      };
      daemon.settings = {
        LogTime = true;
        LogVerbose = false;
        MaxScanSize = cfg.maxScanSize;
        MaxFileSize = cfg.maxFileSize;
        ExcludePath = cfg.excludePaths;
      };
    };

    systemd.services.clamdscan.serviceConfig = {
      CPUWeight = 20;
      IOWeight = 20;
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
    };
  };
}
