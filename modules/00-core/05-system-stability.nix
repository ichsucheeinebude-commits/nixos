# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-034"
# title: "System Stability"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [stability,maintenance,efi,drift-detection,emergency]
# description: "Proactive maintenance: EFI boot entry cleanup, config drift detection, emergency recovery info."
# path: "modules/00-core/05-system-stability.nix"
# provides: [my.stability]
# requires: [00-core]
# links:
#   module: modules/00-core/05-system-stability.nix
# source: _meta/00-core/system-stability.nix (NIXH-00-COR-034)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
{
  options.my.stability.enable = lib.mkEnableOption "System stability services";

  config = lib.mkIf config.my.stability.enable {
    # ── EFI Boot Entry Cleanup ──
    system.activationScripts.cleanEfiEntries = {
      text = ''
        echo "🧹 Cleaning orphaned EFI boot entries..."
        ${pkgs.efibootmgr}/bin/efibootmgr | grep "Boot[0-9]" | grep -vE "systemd-boot|NixOS|Linux|USB|Hard Drive|Network" | \
          ${pkgs.gawk}/bin/awk '{print $1}' | ${pkgs.gnused}/bin/sed 's/Boot//;s/\*//' | \
          xargs -I{} ${pkgs.efibootmgr}/bin/efibootmgr -b {} -B 2>/dev/null || true
      '';
    };

    # ── Config Drift Detector ──
    systemd.services.config-drift-detector = {
      description = "Detect configuration drift";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        USER_CONFIG='/var/lib/nixhome/user-config.json'
        if [ -f "$USER_CONFIG" ] && [ "$(cat "$USER_CONFIG")" != "{}" ]; then
          echo "⚠️ NOTICE: System uses imperative settings."
        fi
      '';
    };

    # ── Emergency Recovery Info ──
    systemd.services.nixhome-emergency = {
      description = "NixOS Emergency Recovery Info";
      serviceConfig = {
        Type = "oneshot";
        StandardOutput = "tty";
        TTYPath = "/dev/tty1";
      };
      script = ''
        echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' > /dev/tty1
        echo '🚨 NIXHOME SETUP FAILED' > /dev/tty1
        echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' > /dev/tty1
        echo 'Boot into previous generation: nixos-rebuild switch --rollback' > /dev/tty1
      '';
    };
  };
}
