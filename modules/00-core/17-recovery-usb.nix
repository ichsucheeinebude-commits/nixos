# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-017"
# title: "Recovery USB Mount"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [core,recovery,usb,luks,disaster-recovery]
# description: "Automated mount logic for physical recovery USB sticks containing ignition seeds. Read-only, manual/triggered mount via udev rule on insertion."
# path: "modules/00-core/17-recovery-usb.nix"
# provides: [my.core.recovery-usb]
# requires: []
# links:
#   module: modules/00-core/17-recovery-usb.nix
# source: mynixos-v5/modules/core/recovery-usb.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

let
  cfg = config.my.core.recovery-usb;
in
{
  # ── Disaster Recovery USB ──
  # Automated mount logic for the physical recovery USB stick.
  # Read-only, triggered on insertion via udev rule.

  options.my.core.recovery-usb = {
    enable = lib.mkEnableOption "Recovery USB stick auto-mount";
    label = lib.mkOption {
      type = lib.types.str;
      default = "RECOVERY_STICK";
      description = "Filesystem label of the recovery USB stick.";
    };
    mountPoint = lib.mkOption {
      type = lib.types.path;
      default = "/mnt/recovery";
      description = "Mount point for the recovery USB.";
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. Mount Point Directory
    systemd.tmpfiles.rules = [
      "d ${cfg.mountPoint} 0700 root root -"
    ];

    # 2. Mount Unit (read-only, noauto)
    systemd.mounts = [
      {
        where = cfg.mountPoint;
        what = "/dev/disk/by-label/${cfg.label}";
        type = "auto";
        options = "ro,noauto";
      }
    ];

    # 3. Service to trigger mount
    systemd.services.recovery-usb-mount = {
      description = "Mount Recovery USB Stick";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.util-linux}/bin/mount ${cfg.mountPoint}";
        ProtectSystem = "strict";
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };

    # 4. UDEV Rule to trigger on insertion
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_LABEL}=="${cfg.label}", TAG+="systemd", ENV{SYSTEMD_WANTS}="recovery-usb-mount.service"
    '';
  };
}
