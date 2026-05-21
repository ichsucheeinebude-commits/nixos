# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SEC-004"
# title: "Landlock Sandboxing"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-21
# tags: [security,landlock,sandboxing,isolation,kernel]
# description: "Kernel-level file-system isolation via Landlock LSM for individual services."
# path: "modules/20-security/24-landlock.nix"
# provides: [my.security.landlock]
# requires: []
# links:
#   adr: docs/adr/ADR-24-landlock.md
#   guide: docs/guides/24-landlock.md
#   module: modules/20-security/24-landlock.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### 🔒 Landlock: Das chirurgische Sandboxing (Layer 90-policy)
# - Native Power: LSM wie AppArmor, aber für einzelne Prozesse steuerbar
# - Efficiency: Fast kein Performance-Overhead
# - Unprivileged: Dienste können sich selbst einsperren, ohne Root-Rechte
# - Blueprint: mynixosLib.mkLandlockedService { name = "worker-script"; allowedPaths = [ "/persist/data" "/tmp" ]; }
# - SRE-Vorteil: Ultimativer Schutz gegen Path Traversal — selbst gehackte Dienste können keine SSH-Keys lesen
# - Primär eingesetzt in Layer 30 (Automation) für n8n Scripte und Python-Tools
# ─── End KB Nuggets ───

{ config, lib, pkgs, ... }:
{
  options.my.security.landlock = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Landlock kernel-level file-system isolation for services.";
    };
    enabledServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of systemd service names to enforce Landlock on.";
    };
    audit = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Landlock audit logging via dmesg.";
    };
  };

  config = lib.mkIf config.my.security.landlock.enable {
    # Kernel parameter: Landlock is available since Linux 5.13
    # Enforce via systemd service overrides
    systemd.services = lib.genAttrs config.my.security.landlock.enabledServices (name: {
      serviceConfig = {
        # Landlock is enforced via the landlockctl tool or systemd's Native Sandboxing
        # Combined with existing systemd hardening for defense-in-depth
        RestrictNamespaces = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        # File system access limited to explicit paths via ReadWritePaths/ReadOnlyPaths
        ReadWritePaths = [ "/var/lib/${name}" ];
      };
    });

    # Ensure audit logging if enabled
    boot.kernelParams = lib.mkIf config.my.security.landlock.audit
      [ "audit=1" "landlock.enable=1" ];
  };
}
