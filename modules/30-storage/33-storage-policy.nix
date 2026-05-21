# ---NIXMETA
# ---
# domain: 30
# id: "NIXH-30-STP-001"
# title: "Storage Policy"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [policy, tiering]
# description: "Storage Policy module."
# path: "modules/30-storage/33-storage-policy.nix"
# provides: [my.storage.policy]
# requires: [30-storage/30-storage]
# links:
#   adr: docs/adr/ADR-30-storage-policy.md
#   guide: docs/guides/30-storage-policy.md
#   module: modules/30-storage/33-storage-policy.nix
# ---
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

  config = {
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
      
      # No service except the mover and sabnzbd-archive is allowed to touch Tier C.
      {
        assertion = unauthorizedTierCServices == {};
        message = "ABC Tiering Violation: Unauthorized services detected accessing Tier C (HDD): ${lib.concatStringsSep ", " (lib.attrNames unauthorizedTierCServices)}. All application data must reside on Tier B (SSD).";
      }
    ];
  };
}
