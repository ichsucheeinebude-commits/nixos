# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SEC-002"
# title: "SOPS Secrets Management"
# type: module
# status: draft
# complexity: 4
# reviewed: 2026-05-21
# tags: [security,sops,secrets,age,pgp,encryption]
# description: "SOPS-nix secrets management with age/PGP key handling and secret injection patterns."
# path: "modules/20-security/22-secrets.nix"
# provides: [my.security.secrets]
# requires: [00-core]
# links:
#   adr: docs/adr/ADR-22-secrets.md
#   guide: docs/guides/22-secrets.md
#   module: modules/20-security/22-secrets.nix
# source: learnings/nix-comm-sops.md
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
let
  cfg = config.my.security.secrets;
in
{
  options.my.security.secrets = {
    enable = lib.mkEnableOption "SOPS secrets management via sops-nix";

    # ── Backend ──
    defaultSopsFormat = lib.mkOption {
      type = lib.types.enum [ "yaml" "json" "dotenv" "binary" ];
      default = "yaml";
      description = "Default format for SOPS secrets files.";
    };

    # ── Age Key ──
    ageKeyFile = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/sops-nix/key.txt";
      description = "Path to the age private key file.";
    };
    ageGenerateKey = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Automatically generate age key if it doesn't exist.";
    };
    agePublicKey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Age public key for encrypting secrets.";
    };

    # ── PGP (alternative to age) ──
    pgpKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of PGP key fingerprints for SOPS encryption.";
    };

    # ── SOPS Files ──
    secrets = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Name of the secret file (relative to sops directory).";
          };
          sopsFile = lib.mkOption {
            type = lib.types.str;
            description = "Path to the encrypted SOPS file.";
          };
          format = lib.mkOption {
            type = lib.types.enum [ "yaml" "json" "dotenv" "binary" ];
            default = cfg.defaultSopsFormat;
            description = "Format of the SOPS file.";
          };
          mode = lib.mkOption {
            type = lib.types.str;
            default = "0440";
            description = "File mode for the rendered secret.";
          };
          owner = lib.mkOption {
            type = lib.types.str;
            default = "root";
            description = "File owner for the rendered secret.";
          };
          group = lib.mkOption {
            type = lib.types.str;
            default = "root";
            description = "File group for the rendered secret.";
          };
          restartUnits = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Systemd units to restart when this secret changes.";
          };
        };
      });
      default = {};
      description = "Attribute set of SOPS secrets to manage.";
    };

    # ── Validation ──
      validation = {
      validateSopsFiles = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Validate SOPS files during nixos-rebuild.";
      };
      requiredKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Required age/PGP keys that must be present.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # SOPS-nix configuration
    sops = {
      # Age key configuration
      age = {
        keyFile = cfg.ageKeyFile;
        generateKey = cfg.ageGenerateKey;
        sshKeyPaths = [];
      };

      # Default SOPS file
      defaultSopsFile = ./secrets.yaml;
      defaultSopsFormat = cfg.defaultSopsFormat;

      # Generate secrets from options
      secrets = lib.mapAttrs' (name: value:
        lib.nameValuePair "sops/${name}" {
          sopsFile = value.sopsFile;
          inherit (value) format mode owner group restartUnits;
        }
      ) cfg.secrets;

      # Validation
      validateSopsFiles = cfg.validation.validateSopsFiles;
    };

    # Ensure age key directory exists
    systemd.tmpfiles.rules = [
      "d /var/lib/sops-nix 0700 root root - -"
    ];

    # Assertion: secrets backend must have at least one key configured
    assertions = [
      {
        assertion = cfg.agePublicKey != null || cfg.pgpKeys != [];
        message = "SOPS secrets require either an age public key or PGP keys to be configured.";
      }
    ];
  };
}
