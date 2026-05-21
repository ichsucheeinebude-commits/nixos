# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-000-COR-REC-002",
#   "title": "USB Recovery Flow",
#   "layer": 0,
#   "category": "core/security",
#   "lastReviewed": "2026-05-15",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["recovery", "usb", "luks"],
#   "description": "Automated mount logic for physical recovery USB sticks containing seeds."
# }
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

let
  recoveryLabel = "RECOVERY_STICK";
  mountPoint = "/mnt/recovery";
in {
  # 🚨 DISASTER RECOVERY (Audit Topic 7)
  # Automated mount logic for the physical recovery USB stick.
  
  # 1. Define the Mount Point
  systemd.tmpfiles.rules = [
    "d ${mountPoint} 0700 root root -"
  ];

  # 2. Mount Unit
  systemd.mounts = [
    {
      where = mountPoint;
      what = "/dev/disk/by-label/${recoveryLabel}";
      type = "auto";
      options = "ro,noauto"; # Read-only, manual/triggered mount only
    }
  ];

  # 3. Service to trigger mount
  systemd.services.recovery-usb-mount = {
    description = "Mount Recovery USB Stick";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/mount ${mountPoint}";
    };
  };

  # 4. UDEV Rule to trigger on insertion
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_LABEL}=="${recoveryLabel}", TAG+="systemd", ENV{SYSTEMD_WANTS}="recovery-usb-mount.service"
  '';

  # 📊 Traceability
  my.meta.recovery_usb = {
    id = "NIXH-COR-REC-USB";
    title = "USB Recovery Flow";
    description = "Physical mount logic for the ignition-seed recovery stick.";
    layer = 0;
    audit.last_reviewed = "2026-05-15";
  };
}
