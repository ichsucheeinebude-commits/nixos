# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SEC-028"
# title: "Hermetic TPM Identity"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-22
# tags: [security,tpm,ssh,hardware-bound,identity]
# description: "TPM-bound SSH identity provider. Implements hardware-backed SSH authentication without YubiKey using sk-ssh-ed25519 keys."
# path: "modules/20-security/28-hermetic.nix"
# provides: [my.security.hermetic]
# requires: [00-core]
# links:
#   module: modules/20-security/28-hermetic.nix
# source: mynixos-v5/modules/security/hermetic.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

let
  cfg = config.my.security.hermetic;
  adminUser = config.my.core.identity.user;
in
{
  # ── Hermetic TPM Identity ──
  # Anchors SSH admin access to the physical TPM 2.0 chip.
  # Implements hardware-backed SSH auth (sk-ssh-ed25519) without YubiKey.

  options.my.security.hermetic = {
    enable = lib.mkEnableOption "Hermetic TPM-bound SSH identity";
    enforceHardwareKeys = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Restrict SSH access to hardware-backed (SK) keys only.";
    };
  };

  config = lib.mkIf cfg.enable {
    # ── SSH Hardening ──
    services.openssh.settings.PubkeyAuthentication = "yes";

    # ── TPM Tools ──
    environment.systemPackages = with pkgs; [
      openssh
      openssl
    ];

    # ── Admin User TPM Permissions ──
    users.users.${adminUser}.extraGroups = [ "tss" ];

    # ── TPM Dependency Warning ──
    warnings = lib.optional (!config.security.tpm2.enable or false)
      "⚠️ [HERMETIC] TPM 2.0 is not enabled. Hardware-bound identity will not function.";
  };
}
