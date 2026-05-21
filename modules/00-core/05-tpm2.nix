# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-006"
# title: "TPM2 Sealing"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [core,tpm2,security,sops]
# description: "TPM2-based secret sealing for SOPS."
# path: "modules/00-core/05-tpm2.nix"
# provides: [my.core.tpm2]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/00-core/05-tpm2.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.core.tpm2 = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable TPM2 for SOPS."; };
  };

  config = lib.mkIf config.my.core.tpm2.enable {
    security.tpm2.enable = true;
  };
}
