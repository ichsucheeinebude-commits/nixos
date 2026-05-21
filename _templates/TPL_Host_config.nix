# @meta -------------------------------------------------
# type: host-config
# status: active
# ------------------------------------------------------
# PURPOSE: System-Level Configuration für eine spezifische Maschine.
# Hier kommen Hostname, Bootloader, Imports, Impermanence und SOPS rein.
# Hardware-UUIDs gehören in hardware-nixos.nix (nixos-generate-config).
#
# TRACEABILITY:
# - Linked Guides: docs/guides/ (alle Domains die dieser Host nutzt)
# - Linked ADRs:   docs/adr/ADR-00-core.md (Foundation-Entscheidungen)
# - Imported Modules: modules/00-core.nix bis modules/90-policy.nix
# - Template: _templates/TPL_Host_config.nix

{ config, pkgs, lib, inputs, ... }:

{
  # ── Imports ──────────────────────────────────────────────────────────
  # Host-spezifische Hardware (nixos-generate-config output)
  imports = [
    ./hardware-nixos.nix
    # Domain-Module — nur die aktivieren die dieser Host braucht:
    # ../../modules/00-core.nix
    # ../../modules/10-network.nix
    # ../../modules/20-security.nix
    # ../../modules/30-storage.nix
    # ../../modules/40-monitoring.nix
    # ../../modules/50-media.nix
    # ../../modules/60-apps.nix
    # ../../modules/70-forge.nix
    # ../../modules/80-gaming.nix
    # ../../modules/90-policy.nix
  ];

  # ── Boot ─────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Identity ─────────────────────────────────────────────────────────
  networking.hostName = "REPLACE_HOST";
  time.timeZone       = "Europe/Berlin";
  i18n.defaultLocale  = "de_DE.UTF-8";

  # ── Impermanence (optional — auskommentieren wenn nicht gewünscht) ──
  # / ist ein RAM-Disk — wird bei jedem Boot geleert
  # fileSystems."/" = {
  #   device  = "none";
  #   fsType  = "tmpfs";
  #   options = [ "defaults" "size=2G" "mode=755" ];
  # };
  #
  # environment.persistence."/persist" = {
  #   hideMounts = true;
  #   directories = [
  #     "/var/log"
  #     "/var/lib/nixos"
  #     "/etc/ssh"
  #   ];
  #   files = [ "/etc/machine-id" ];
  # };

  # ── SOPS Secrets ─────────────────────────────────────────────────────
  # sops = {
  #   defaultSopsFile = ../../secrets/REPLACE_HOST.yaml;
  #   age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  # };

  # ── State ────────────────────────────────────────────────────────────
  # NICHT nach erstem Deploy ändern!
  system.stateVersion = "24.11";
}
