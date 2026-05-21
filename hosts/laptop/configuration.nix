# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-HOST-LAPTOP",
#   "title": "Host: laptop",
#   "layer": 99,
#   "category": "host",
#   "lastReviewed": "YYYY-MM-DD",
#   "reviewedBy": "moritz",
#   "status": "draft",
#   "complexity": 2,
#   "description": "Host configuration for laptop"
# }
# ---ENDNIXMETA

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-nixos.nix
    ../../modules/00-core.nix
    ../../modules/10-network.nix
    ../../modules/20-security.nix
    # Weitere Module nach Bedarf eintragen
  ];

  # ── Boot ───────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Identity ───────────────────────────────────────────────────────────
  networking.hostName = "laptop";
  time.timeZone       = "Europe/Berlin";
  i18n.defaultLocale  = "de_DE.UTF-8";

  # ── SOPS Secrets ──────────────────────────────────────────────────────
  sops = {
    # defaultSopsFile = ../../secrets/laptop.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  system.stateVersion = "24.11";
}
