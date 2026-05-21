# ---NIXMETA
# ---
# domain: 90
# id: "NIXH-90-POL-004"
# title: "Security Assertions"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [security,assertions,compliance,firewall,ssh]
# description: "Global security assertions to ensure critical hardening settings are active."
# path: "modules/90-policy/91-security-assertions.nix"
# provides: [my.policy.securityAssertions]
# requires: [00-core]
# links:
#   module: modules/90-policy/91-security-assertions.nix
# source: _meta/90-policy/security-assertions.nix (NIXH-90-POL-004)
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.policy.securityAssertions;
  must = assertion: message: { inherit assertion message; };
  sshSettings = config.services.openssh.settings;
in
{
  options.my.policy.securityAssertions = {
    enable = lib.mkEnableOption "Security assertion enforcement";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (must (config.networking.firewall.enable == true) "[SEC-NET-001] Firewall must be active.")
      (must (config.networking.nftables.enable == true) "[SEC-NET-002] NFTables must be enabled.")
      (must (sshSettings.PermitRootLogin == "no") "[SEC-SSH-002] Root SSH login must be disabled.")
    ];
  };
}
