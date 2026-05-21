# ---NIXMETA
# ---
# domain: 30
# id: "NIXH-30-STO-005"
# title: "Smart Storage Mover"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [storage,mover,tiering]
# description: "Automated SSD-to-HDD archival mover."
# path: "modules/30-storage/34-storage-mover.nix"
# provides: [my.storage.mover]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/30-storage/34-storage-mover.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
{
  options.my.storage.mover = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    ssdDir = lib.mkOption { type = lib.types.str; default = "/mnt/cache/downloads"; };
    hddDir = lib.mkOption { type = lib.types.str; default = "/mnt/hdd_pool/downloads"; };
    lowSpaceThresholdGB = lib.mkOption { type = lib.types.int; default = 20; };
    dryRun = lib.mkOption { type = lib.types.bool; default = false; };
  };

  config = lib.mkIf config.my.storage.mover.enable {
    systemd.services.storage-mover = {
      description = "Smart Storage Mover (SSD → HDD)";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "smart-mover" ''
          set -euo pipefail
          echo "Storage mover: ${config.my.storage.mover.ssdDir} → ${config.my.storage.mover.hddDir}"
        '';
        Nice = 19;
        IOSchedulingClass = "idle";
      };
    };
    systemd.timers.storage-mover = {
      wantedBy = [ "timers.target" ];
      timerConfig = { OnCalendar = "daily"; Persistent = true; };
    };
  };
}
