# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SEC-027"
# title: "Hardened Core"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-22
# tags: [security,hardening,slimming,kernel-lockdown]
# description: "Service slimming and system-level hardening. Disables unnecessary services, configures kernel lockdown mode, hides process info."
# path: "modules/20-security/27-hardened-core.nix"
# provides: [my.security.hardened]
# requires: []
# links:
#   module: modules/20-security/27-hardened-core.nix
# source: mynixos-v5/modules/security/hardened-core.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:

let
  cfg = config.my.security.hardened;
in
{
  # ── Hardened Core ──
  # Service slimming, kernel lockdown, and system-level hardening.

  options.my.security.hardened = {
    enable = lib.mkEnableOption "Hardened Core security hardening";
    lockdownMode = lib.mkOption {
      type = lib.types.enum [ "strict" "permissive" ];
      default = "permissive";
      description = "strict: Kernel lockdown enabled; permissive: Kernel lockdown disabled.";
    };
  };

  config = lib.mkIf cfg.enable {
    # ── Kernel Lockdown ──
    security.lockKernelModules = cfg.lockdownMode == "strict";
    security.hideProcessInformation = true;

    # ── Service Slimming ──
    # Only enable pcscd for YubiKey / Hardware Keys
    services.pcscd.enable = true;

    # Disable unnecessary services
    systemd.services = {
      accounts-daemon.enable = false;
      ModemManager.enable = false;
      udisks2.enable = false;
      upower.enable = false;
      cups.enable = false;
      bluetooth.enable = false;
      wpa_supplicant.enable = false;
    };

    # Mask unneeded units
    systemd.maskedUnits = [
      "plymouth-quit-wait.service"
      "systemd-networkd-wait-online.service"
    ];

    # Disable coredump (reduces attack surface / disk usage)
    systemd.coredump.enable = false;
  };
}
