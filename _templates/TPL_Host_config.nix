# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-HOST-REPLACE_HOSTNAME",
#   "title": "Host: REPLACE_HOSTNAME",
#   "layer": 99,
#   "category": "host",
#   "lastReviewed": "YYYY-MM-DD",
#   "reviewedBy": "moritz",
#   "status": "draft",
#   "complexity": 3,
#   "description": "Host-specific configuration for REPLACE_HOSTNAME"
# }
# ---ENDNIXMETA

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-nixos.nix
    # ../../modules/00-core.nix
    # Weitere Module nach Bedarf
  ];

  # ── Boot ───────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Identity ───────────────────────────────────────────────────────────
  networking.hostName = "REPLACE_HOSTNAME";
  time.timeZone       = "Europe/Berlin";
  i18n.defaultLocale  = "de_DE.UTF-8";

  system.stateVersion = "24.11";
}
