# ---NIXMETA
# ---
# domain: 30
# id: "NIXH-30-STR-001"
# title: "Storage Pool (MergerFS)"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [storage, mergerfs]
# description: "Storage Pool (MergerFS) module."
# path: "modules/30-storage/30-storage.nix"
# provides: [my.storage.pool]
# requires: [00-core/01-configs-registry]
# links:
#   adr: docs/adr/ADR-30-storage.md
#   guide: docs/guides/30-storage.md
#   module: modules/30-storage/30-storage.nix
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
  
  cfg = config.my.media.storagePool;
  # Pfade aus SSoT Registry
  srePaths = config.my.configs.paths;
in
{

  options.my.media.storagePool = {
    enable = lib.mkEnableOption "Unified MergerFS Storage Pool";
  };

  config = lib.mkIf cfg.enable {
    systemd.mounts = [
      {
        description = "Unified Storage Pool (MergerFS)";
        where = "/storage";
        what = "/mnt/cache:/mnt/hdd1:/mnt/hdd2";
        type = "fuse.mergerfs";
        options = "allow_other,use_ino,cache.files=partial,cache.entry=3600,cache.attr=3600,cache.readdir=true,dropcacheonclose=true,category.create=mfs,minfreespace=50G,fsname=mergerfs-pool,noatime,x-systemd.after=local-fs.target,x-systemd.requires=local-fs.target";
        wantedBy = [ "multi-user.target" ];
      }
      {
        description = "App Data Synergy Pool (Tier A/B)";
        where = "/mnt/app-data-synergy";
        what = "${srePaths.appData}:${srePaths.tierB}/appdata";
        type = "fuse.mergerfs";
        options = "allow_other,use_ino,cache.files=off,dropcacheonclose=true,category.create=mfs,minfreespace=50G,fsname=app-data-synergy,noatime,x-systemd.after=local-fs.target,x-systemd.requires=local-fs.target";
        wantedBy = [ "multi-user.target" ];
      }
    ];

    systemd.services.hdd-inode-warmer = {
      description = "Refined Inode Warmer for HDD Ghost-Tree";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.findutils}/bin/find /mnt/hdd_pool -mindepth 1 -maxdepth 5 -exec stat {} +";
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
      };
    };

    systemd.timers.hdd-inode-warmer = {
      description = "Timer for HDD Metadata Cache Warmer";
      timerConfig = {
        OnCalendar = "00/6:00:00";
        Unit = "hdd-inode-warmer.service";
      };
      wantedBy = [ "timers.target" ];
    };

    # Monitors Load_Cycle_Count changes without waking the disks.
    systemd.services.hdd-spinup-monitor = {
      description = "Monitor HDD Spinups via SMART attributes";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash /etc/nixos/scripts/hdd-spinup-monitor.sh";
        User = "root";
        Environment = "NTFY_URL=${config.my.configs.identity.ntfyUrl}";
      };
      path = with pkgs; [ smartmontools gawk utillinux coreutils curl ];
    };

    systemd.timers.hdd-spinup-monitor = {
      description = "Timer for HDD Spinup Monitoring";
      timerConfig = {
        OnCalendar = "*:0/5"; # Every 5 minutes
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };

    systemd.services.storage-init = {
      description = "Storage Path Initialization";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ProtectSystem = "strict";
        ProtectHome = true;
      };
      script = ''
        # Verzeichnisse anlegen
        mkdir -p /storage/{media,downloads,documents,backups}
        mkdir -p ${srePaths.tierB}/appdata
        # Rechte setzen (Media-Gruppe)
        chown -R root:media /storage/media /storage/downloads
        chmod -R 775 /storage/media /storage/downloads
      '';
    };

    services.udev.extraRules = ''
      SUBSYSTEM=="block", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", RUN+="${pkgs.hdparm}/bin/hdparm -S 120 /dev/%k"
    '';

    environment.systemPackages = with pkgs; [ mergerfs util-linux hdparm smartmontools ];
  };
}
