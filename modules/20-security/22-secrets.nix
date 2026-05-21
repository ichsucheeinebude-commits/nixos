# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SEC-003"
# title: "Secrets Management"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [security,sops,secrets]
# description: "SOPS-based secrets management."
# path: "modules/20-security/22-secrets.nix"
# provides: [my.security.secrets]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/20-security/22-secrets.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.security.secrets = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    ageKeyFile = lib.mkOption { type = lib.types.str; default = "/etc/sops-nix/age-keys.txt"; };
    defaultSopsFile = lib.mkOption { type = lib.types.path; default = null; };
  };

  config = lib.mkIf config.my.security.secrets.enable {
    sops = {
      defaultSopsFile = lib.mkIf (config.my.security.secrets.defaultSopsFile != null) config.my.security.secrets.defaultSopsFile;
      age.keyFile = lib.mkIf (config.my.security.secrets.ageKeyFile != "") config.my.security.secrets.ageKeyFile;
      secrets = {};
    };
  };
}
