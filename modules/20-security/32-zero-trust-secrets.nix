# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SEC-032"
# title: "Zero-Trust Secrets Decryptor"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-22
# tags: [security,sops,tpm2,zero-trust,secrets]
# description: "TPM2-backed native secrets decryptor service for hardware-bound identity. Provides a sandboxed systemd service for SOPS decryption."
# path: "modules/20-security/32-zero-trust-secrets.nix"
# provides: [my.security.zeroTrustSecrets]
# requires: [00-core]
# links:
#   module: modules/20-security/32-zero-trust-secrets.nix
# source: mynixos-v5/modules/security/zero-trust-secrets.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

let
  cfg = config.my.security.zeroTrustSecrets;
in
{
  # ── Zero-Trust Secrets Decryptor ──
  # Native SOPS decryptor with TPM2-backed hardware identity.
  # Sandboxed systemd service for secrets decryption.

  options.my.security.zeroTrustSecrets = {
    enable = lib.mkEnableOption "Zero-Trust native SOPS decryptor";
    secretsFile = lib.mkOption {
      type = lib.types.path;
      default = ../../secrets/secrets.yaml;
      description = "Path to the encrypted SOPS secrets file.";
    };
    decryptorScript = lib.mkOption {
      type = lib.types.path;
      default = ../../scripts/secrets-decryptor.sh;
      description = "Path to the decryptor shell script.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.secrets-decryptor = {
      description = "Zero-Trust Native Secrets Decryptor";
      wantedBy = [ "multi-user.target" ];
      before = [ "network.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
        ExecStart = "${pkgs.bash}/bin/bash ${cfg.decryptorScript}";

        # Sandboxing
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        CapabilityBoundingSet = "";
        PrivateUsers = true;
        RestrictAddressFamilies = [ "AF_UNIX" ];
        SystemCallFilter = [ "@system-service" "~@privileged" "~@mount" "~@swap" ];

        # Paths: TPM device access, secrets output
        ReadWritePaths = [ "/run/secrets" ];
        DeviceAllow = [ "/dev/tpmrm0 rw" ];
      };

      path = with pkgs; [ tpm2-tools sops age ];

      environment = {
        SOPS_FILE = toString cfg.secretsFile;
      };
    };

    environment.systemPackages = [ pkgs.sops pkgs.age ];
  };
}
