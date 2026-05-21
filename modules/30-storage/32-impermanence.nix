# ---NIXMETA
# ---
# domain: 30
# id: "NIXH-30-IMP-001"
# title: "Impermanence"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [impermanence, erase]
# description: "Impermanence module."
# path: "modules/30-storage/32-impermanence.nix"
# provides: [my.storage.impermanence]
# requires: [30-storage/30-storage]
# links:
#   adr: docs/adr/ADR-30-impermanence.md
#   guide: docs/guides/30-impermanence.md
#   module: modules/30-storage/32-impermanence.nix
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  in
 {

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
        "/home/${config.my.core.identity.user}"
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

    fileSystems."/" = lib.mkForce {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=4G" "mode=755" ];
    };

    users.groups.proc = {}; # Escape-hatch for monitoring
  };
}
