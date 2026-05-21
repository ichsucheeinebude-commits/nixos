# ---NIXMETA
# ---
# domain: 70
# id: "NIXH-70-FRG-002"
# title: "Semaphore Ansible"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [forge,semaphore,ansible]
# description: "Ansible Semaphore web UI."
# path: "modules/70-forge/71-semaphore.nix"
# provides: [my.forge.semaphore]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/70-forge/71-semaphore.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.forge.semaphore = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
  };
}
