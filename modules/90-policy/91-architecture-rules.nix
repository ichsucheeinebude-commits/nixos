# ---NIXMETA
# ---
# domain: 90
# id: "NIXH-90-ARC-001"
# title: "Architecture Rules"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [architecture, rules]
# description: "Architecture Rules module."
# path: "modules/90-policy/91-architecture-rules.nix"
# provides: [my.policy.arch_rules]
# requires: []
# links:
#   adr: docs/adr/ADR-90-architecture-rules.md
#   guide: docs/guides/90-architecture-rules.md
#   module: modules/90-policy/91-architecture-rules.nix
# ---
# ---ENDNIXMETA

# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-000-COR-ARC-001",
#   "title": "Architecture Rule Engine",
#   "layer": 0,
#   "category": "core/policy",
#   "lastReviewed": "2026-05-17",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["policy", "architecture", "guard"],
#   "description": "Hard-coded build-time assertions to prevent architectural drift and forbidden technologies."
# }
# ---ENDNIXMETA

{ config, lib, ... }:

let
  inherit (lib) mkIf;
  
  # anchor: architecture-violations
  # Architektur-Verstöße, die den Build stoppen
  violations = [
    {
      # anchor: docker-ban
      assertion = !(config.virtualisation.docker.enable or false);
      message = "🛑 ARCH-FAIL: Docker is forbidden. Use native systemd services via mkService.";
    }
    {
      # anchor: tailscale-ban
      assertion = !(config.services.tailscale.enable or false);
      message = "🛑 ARCH-FAIL: Tailscale is forbidden. Use native WireGuard logic.";
    }
    {
      assertion = !(config.services.cron.enable or false);
      message = "🛑 ARCH-FAIL: Cron is forbidden. Use systemd timers.";
    }
    {
      assertion = config.networking.nftables.enable;
      message = "🛑 ARCH-FAIL: Legacy iptables detected. NFTables is mandatory.";
    }
    {
      # anchor: stateless-root
      assertion = config.fileSystems."/".fsType == "tmpfs";
      message = "🛑 ARCH-FAIL: Stateless Root (tmpfs) is mandatory for v7.1 Strict.";
    }
    {
      # anchor: flake-parts-ban
      # Verhindert die Nutzung von flake-parts oder ähnlichen Frameworks durch Prüfung von Optionen
      # (Beispiel: flake-parts setzt oft spezifische Unteroptionen)
      assertion = !(config ? flake-parts);
      message = "🛑 ARCH-FAIL: 'flake-parts' detected. External flake frameworks are forbidden.";
    }
  ];

in {
  options.my.meta.architecture_rules = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  config = {
    # Erzwungene Regeln für das gesamte System
    assertions = violations;
  };
}
