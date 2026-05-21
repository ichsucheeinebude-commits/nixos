# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-000-COR-IMP-001",
#   "title": "Impermanence Core",
#   "layer": 0,
#   "category": "core/persistence",
#   "lastReviewed": "2026-05-14",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 3,
#   "tags": ["persistence", "stateless", "impermanence"],
#   "description": "System-wide persistence for stateless root-on-RAM setup. Removed /nix/var for v6.0 compliance."
# }
# ---ENDNIXMETA

{ config, lib, ... }:
let
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-00-COR-036";
    title = "Impermanence Core";
    description = "System-wide persistence for stateless root-on-RAM setup. Manages declarative state on /persist.";
    layer = 0;
    nixpkgs.category = "core/persistence";
    capabilities = ["persistence/stateless" "system/impermanence" "storage/tiering"];
    audit.last_reviewed = "2026-05-14";
    audit.complexity = 3;
  };
in
 {
  options.my.meta.impermanence = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  # 💾 HARDENED IMPERMANENCE (anchor: persistence-core)
  # Verwaltet die systemweiten Persistenz-Pfade für das Stateless-Root (tmpfs).
 # App-spezifische Pfade werden automatisch via mkService (lib-helpers) registriert.

  options.my.persistence = {
    directories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of directories to persist on /persist.";
    };
    files = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of files to persist on /persist.";
    };
  };

  config = {
    # 🛡️ SYSTEM PERSISTENCE (Tier A: NVMe State)
    # 🧹 BLANK SNAPSHOT (anchor: blank-snapshot)
  environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/lib/sops-nix"
        "/var/lib/bluetooth"
        "/var/lib/pocket-id"
        "/var/lib/caddy"
        "/var/lib/geoip"
        "/var/lib/postgresql" # PostgreSQL socket, database runs on tmpfs
        "/var/lib/blocky"
        "/var/log/vector"
        "/home/moritz"
        "/etc/nixos"
        "/etc/NetworkManager/system-connections"
      ] ++ config.my.persistence.directories;
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ] ++ config.my.persistence.files;
    };

    # 🚀 ROOT-ON-RAM SETUP (Stateless Manifesto)
    fileSystems."/" = lib.mkForce {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=4G" "mode=755" ];
    };

    users.groups.proc = {}; # Escape-hatch for monitoring
  };
}
