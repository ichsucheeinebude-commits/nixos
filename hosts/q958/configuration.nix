# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-HOST-Q958",
#   "title": "Host: q958 (Fujitsu Q958 Server)",
#   "layer": 99,
#   "category": "host",
#   "lastReviewed": "YYYY-MM-DD",
#   "reviewedBy": "moritz",
#   "status": "draft",
#   "complexity": 3,
#   "description": "Host configuration for Fujitsu Q958 server"
# }
# ---ENDNIXMETA

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-nixos.nix
    ../../modules/00-core.nix
    ../../modules/10-network.nix
    ../../modules/20-security.nix
    ../../modules/30-storage.nix
    ../../modules/40-monitoring.nix
    ../../modules/50-media.nix
    ../../modules/60-apps.nix
    ../../modules/70-forge.nix
    ../../modules/80-gaming.nix
    ../../modules/90-policy.nix
  ];

  # ── Boot ───────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Identity ───────────────────────────────────────────────────────────
  networking.hostName = "q958";
  time.timeZone       = "Europe/Berlin";
  i18n.defaultLocale  = "de_DE.UTF-8";

  # ── Impermanence ───────────────────────────────────────────────────────
  # / ist ein RAM-Disk — wird bei jedem Boot geleert
  fileSystems."/" = {
    device  = "none";
    fsType  = "tmpfs";
    options = [ "defaults" "size=2G" "mode=755" ];
  };

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      { directory = "/etc/ssh"; mode = "0755"; }
    ];
    files = [ "/etc/machine-id" ];
  };

  # ── SOPS Secrets ──────────────────────────────────────────────────────
  sops = {
    # defaultSopsFile = ../../secrets/q958.yaml;
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
  };

  system.stateVersion = "24.11";
}
