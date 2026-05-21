# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-AUTO-GEN",
#   "title": "Auto Generated",
#   "layer": 99,
#   "category": "auto/gen",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["auto-generated"],
#   "description": "Auto-migrated module to NIXMETA 2.0."
# }
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-00-COR-038";
    title = "TPM 2.0 Hardware Stack";
    description = "Enables support for the hardware-bound root of trust on Fujitsu Q958.";
    layer = 0;
    nixpkgs.category = "core/hardware";
    capabilities = ["security/tpm2" "identity/hardware-bound"];
    audit.last_reviewed = "2026-05-19";
    audit.complexity = 2;
  };
in
{
  options.my.meta.tpm2 = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  # 🛡️ TPM 2.0 HARDWARE STACK (v7.1 Strict)
  # Enables support for the hardware-bound root of trust on Fujitsu Q958.
  
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true; # Required for TPM-backed SSH keys
    abrmd.enable = true;  # Userspace Resource Manager
    tctiEnvironment.enable = true;
  };

  environment.systemPackages = with pkgs; [
    tpm2-tools
    tpm2-tss
    tpm2-pkcs11
    age-plugin-tpm
  ];

  # Allow access to TPM for certain services (handled in lib-helpers.nix)
  # But we also add the kernel modules explicitly just in case
  boot.kernelModules = [ "tpm_tis" ];
}
