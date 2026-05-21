# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SEC-030"
# title: "Runtime Security Watchdog"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [security,watchdog,runtime,nftables,ssh]
# description: "Runtime security monitoring that checks active system state (not just config). Verifies nftables, kernel lockdown, SSH root login, and admin-zone alias."
# path: "modules/20-security/30-runtime-guard.nix"
# provides: [my.security.runtime-guard]
# requires: []
# links:
#   module: modules/20-security/30-runtime-guard.nix
# source: mynixos-v5/modules/security/runtime-guard.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

let
  cfg = config.my.security.runtime-guard;
in
{
  # ── Runtime Security Watchdog ──
  # Checks active system state and alerts on violations.
  # Runs on a configurable schedule via systemd timer.

  options.my.security.runtime-guard = {
    enable = lib.mkEnableOption "Runtime security monitoring watchdog";
    interval = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
      description = "Systemd OnCalendar schedule for the watchdog check.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.security-watchdog = {
      description = "Runtime Security Check";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ProtectSystem = "strict";
        PrivateTmp = true;
        NoNewPrivileges = true;
      };

      script = ''
        set -euo pipefail

        # 1. Check Firewall (nftables active)
        if ! ${pkgs.nftables}/bin/nft list tables | ${pkgs.gnugrep}/bin/grep -q -- "inet filter"; then
          echo "🛑 SECURITY ALERT: nftables filter table is MISSING!"
          exit 1
        fi

        # 2. Check Kernel Lockdown Status
        if [ -d /sys/kernel/security/lockdown ]; then
          LOCKDOWN=$(${pkgs.coreutils}/bin/cat /sys/kernel/security/lockdown | ${pkgs.gnugrep}/bin/grep -o '\[.*\]' | ${pkgs.gnused}/bin/s 's/\[//;s/\]//')
          if [ "$LOCKDOWN" != "confidentiality" ] && [ "$LOCKDOWN" != "integrity" ]; then
            echo "🛑 SECURITY ALERT: Kernel Lockdown is NOT effective (Current: $LOCKDOWN)"
          fi
        fi

        # 3. Check SSH Root Login (Runtime check via sshd -T)
        if ${pkgs.openssh}/bin/sshd -T | ${pkgs.gnugrep}/bin/grep -q -- "permitrootlogin yes"; then
          echo "🛑 SECURITY ALERT: sshd allows root login in active config!"
          exit 1
        fi

        # 4. Check Admin-Zone Alias (127.0.0.2)
        if ! ${pkgs.iproute2}/bin/ip addr show lo | ${pkgs.gnugrep}/bin/grep -q "127.0.0.2"; then
          echo "🛑 SECURITY ALERT: Admin-Hangar Alias 127.0.0.2 is MISSING!"
          exit 1
        fi
      '';
    };

    systemd.timers.security-watchdog = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.interval;
        Persistent = true;
      };
    };
  };
}
