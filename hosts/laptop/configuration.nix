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
    # 00-core
    ../../modules/00-core/00-principles.nix
    ../../modules/00-core/01-configs-registry.nix
    ../../modules/00-core/02-nix-tuning.nix
    ../../modules/00-core/03-hardware-profile.nix
    ../../modules/00-core/04-boot-safeguards.nix
    ../../modules/00-core/05-tpm2.nix
    ../../modules/00-core/06-zram-swap.nix
    ../../modules/00-core/07-locale-system.nix
    ../../modules/00-core/08-users-shell.nix
    ../../modules/00-core/09-postgresql.nix
    # 10-network
    ../../modules/10-network/10-network.nix
    ../../modules/10-network/11-firewall.nix
    ../../modules/10-network/12-ssh.nix
    ../../modules/10-network/13-ssh-rescue.nix
    ../../modules/10-network/14-blocky.nix
    ../../modules/10-network/15-caddy.nix
    ../../modules/10-network/16-dns-automation.nix
    ../../modules/10-network/17-pocket-id.nix
    ../../modules/10-network/18-ddns-updater.nix
    ../../modules/10-network/19-zigbee-stack.nix
    # 20-security
    ../../modules/20-security/20-fail2ban.nix
    ../../modules/20-security/21-kernel-hardening.nix
    ../../modules/20-security/22-secrets.nix
    ../../modules/20-security/23-secrets-schema.nix
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
