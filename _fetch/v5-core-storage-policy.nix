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

{ config, lib, ... }:
let
  cfg = config.my.configs;
  paths = cfg.paths;
  
  # Services allowed to touch Tier C (Exemptions)
  # v6.1 Strict Spec Enforcement
  tierCExemptions = [
    "storage-mover"
    "sabnzbd"
    "hdd-inode-warmer"
    "storage-init"
    "nixhome-emergency"
    "rotate-vector-logs"
    # Media servers: read-only access to cold archive via MergerFS
    "jellyfin"
    "navidrome"
    "audiobookshelf"
  ];

  # Helper to check if any path in a list points to Tier C
  usesTierC = pathList: lib.any (p: lib.strings.hasInfix paths.tierC (toString p)) pathList;

  # Identify unauthorized services
  unauthorizedTierCServices = lib.filterAttrs (name: svc: 
    let
      # Gather all strings that could contain a path
      configStrings = lib.flatten [
        (svc.serviceConfig.ReadWritePaths or [])
        (svc.serviceConfig.BindPaths or [])
        (svc.serviceConfig.BindReadOnlyPaths or [])
        (svc.serviceConfig.ExecStart or [])
        (svc.serviceConfig.ExecStartPre or [])
        (svc.serviceConfig.ExecStartPost or [])
        (svc.serviceConfig.EnvironmentFile or [])
      ];
    in
    !(lib.elem name tierCExemptions) && (usesTierC configStrings)
  ) config.systemd.services;

in
{
  options.my.meta.storage_policy = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  config = {
    # 🛡️ HARDWARE VALIDATION ASSERTIONS
    # Ensure paths are mounted on the correct physical media
    assertions = [
      {
        assertion = paths.tierA == "/persist";
        message = "ABC Tiering Error: Tier A (NVMe) MUST be mounted at /persist.";
      }
      {
        assertion = paths.tierB == "/mnt/cache";
        message = "ABC Tiering Error: Tier B (SSD) MUST be mounted at /mnt/cache.";
      }
      {
        assertion = paths.tierC == "/mnt/hdd_pool";
        message = "ABC Tiering Error: Tier C (HDD) MUST be mounted at /mnt/hdd_pool.";
      }
      
      # 🛡️ GLOBAL TIER C EXCLUSION (v6.1 Strict Spec)
      # No service except the mover and sabnzbd-archive is allowed to touch Tier C.
      {
        assertion = unauthorizedTierCServices == {};
        message = "ABC Tiering Violation: Unauthorized services detected accessing Tier C (HDD): ${lib.concatStringsSep ", " (lib.attrNames unauthorizedTierCServices)}. All application data must reside on Tier B (SSD).";
      }
    ];
  };
}
