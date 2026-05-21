# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-018"
# title: "Admin Task Triggers"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-22
# tags: [core,admin,systemd,cli,triggers]
# description: "Hardened systemd units for administrative tasks. Usage: sudo systemctl start admin-<trigger>. Provides rebuild, garbage collection, and extensible trigger points."
# path: "modules/00-core/18-admin-triggers.nix"
# provides: [my.core.admin-triggers]
# requires: []
# links:
#   module: modules/00-core/18-admin-triggers.nix
# source: mynixos-v5/modules/core/admin-triggers.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

{
  # ── Admin Task Triggers ──
  # Hardened systemd units for administrative tasks.
  # Usage: sudo systemctl start admin-<trigger>

  options.my.core.admin-triggers = {
    enable = lib.mkEnableOption "Admin task triggers (rebuild, GC, etc.)";
    flakeRef = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nixos#nixhome";
      description = "NixOS flake reference for admin-rebuild.";
    };
  };

  config = lib.mkIf config.my.core.admin-triggers.enable {
    systemd.services = {
      "admin-rebuild" = {
        description = "NixOS System Rebuild (Switch)";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ${config.my.core.admin-triggers.flakeRef}";
          StandardOutput = "journal";
          ProtectSystem = "strict";
          PrivateTmp = true;
          NoNewPrivileges = true;
        };
      };

      "admin-gc" = {
        description = "NixOS Garbage Collection";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.nix}/bin/nix-collect-garbage -d";
          ProtectSystem = "strict";
          PrivateTmp = true;
          NoNewPrivileges = true;
        };
      };

      "admin-update-ca" = {
        description = "Update CA Certificates";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.coreutils}/bin/true";
          # Placeholder: replace with actual CA update script when available.
        };
      };
    };
  };
}
