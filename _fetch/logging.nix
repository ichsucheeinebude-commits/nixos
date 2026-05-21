{lib, ...}: let
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-00-COR-021";
    title = "Logging (SRE Monitor Mode)";
    description = "Volatile high-performance logging with strict retention policies and disabled rate-limiting for debugging.";
    layer = 00;
    nixpkgs.category = "system/logging";
    capabilities = ["system/logging" "performance/volatile-storage"];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 2;
  };
in {
  options.my.meta.logging = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  config = {
    services.journald.extraConfig = ''
      Storage=volatile
      RuntimeMaxUse=500M
      RuntimeMaxFileSize=100M
      MaxRetentionSec=5day
      Compress=yes
      RateLimitIntervalSec=0
      RateLimitBurst=0
      ForwardToSyslog=no
      ForwardToConsole=no
      MaxLevelStore=debug
      MaxLevelConsole=info
    '';
  };
}
/**
* ---
 * technical_integrity:
 *   checksum: sha256:6a843a5bd877dcb9233d310d6248665c33a0749ccbe56d5da707307c2265b0f1
 *   eof_marker: NIXHOME_VALID_EOF* ---
*/

