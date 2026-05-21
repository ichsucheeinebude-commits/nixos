{
  config,
  lib,
  pkgs,
  ...
}: let
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-00-COR-005";
    title = "Boot Safeguard";
    description = "Prevent /boot overflow with aggressive GC, RAM-testing and pre-build safety checks.";
    layer = 00;
    nixpkgs.category = "system/boot";
    capabilities = ["system/maintenance" "safety/circuit-breaker"];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 2;
  };

  bootSpaceCheck = pkgs.writeShellScriptBin "boot-space-check" ''
    set -euo pipefail
    BOOT_USAGE=$(df /boot --output=pcent | tail -1 | tr -dc '0-9')
    if [ "$BOOT_USAGE" -gt 85 ]; then
      echo "🚨 KRITISCH: /boot ist zu $((BOOT_USAGE))% voll!"
      exit 1
    fi
    echo "✅ /boot Space: $((BOOT_USAGE))% (OK)"
  '';
in {
  options.my.meta.boot_safeguard = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  config = lib.mkIf (config.my.services.bootSafeguard.enable or true) {
    # ── GARBAGE COLLECTION (Nixpkgs Standard) ────────────────────────────────
    nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
      persistent = true;
      randomizedDelaySec = "1h"; # Lastverteilung
    };

    # ── BOOTLOADER TUNING (SRE Expert) ───────────────────────────────────────
    boot.loader.systemd-boot = {
      enable = true;
      configurationLimit = lib.mkForce 5; # Strikte Limitierung für kleine ESP
      memtest.enable = true; # 💎 Gamechanger: RAM-Test im Boot-Menü
      consoleMode = "max"; # Saubere Auflösung auf TTY
    };

    # ── MONITORING ───────────────────────────────────────────────────────────
    systemd.services.boot-space-monitor = {
      description = "Boot Partition Space Monitor";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${bootSpaceCheck}/bin/boot-space-check";
      };
    };

    systemd.timers.boot-space-monitor = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "daily";
        OnBootSec = "5min";
        Persistent = true;
      };
    };

    environment.systemPackages = [bootSpaceCheck];
    programs.bash.shellAliases = {
      boot-check = "${bootSpaceCheck}/bin/boot-space-check";
      nsw-safe = "sudo boot-space-check && sudo nixos-rebuild switch";
    };
  };
}
/**
* ---
 * technical_integrity:
 *   checksum: sha256:90cf5bae9d40d2ceac6f6e6752ec69a353f43c7cefa7ed62269fae4bfd3a952c
 *   eof_marker: NIXHOME_VALID_EOF* ---
*/

