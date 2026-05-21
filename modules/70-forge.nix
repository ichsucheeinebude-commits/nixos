# ---NIXMETA---
# domain: 70-forge
# id: NIXH-70-FOR-001
# status: draft
# provides:
#   - my.forge.enable
# requires:
#   - 00-core
#   - 10-network
#   - 20-security
# adr: ADR-70-forge.md
# guide: 70-forge.md
# complexity: 2
# reviewed: YYYY-MM-DD
# ---ENDNIXMETA---
#
# PURPOSE: Forgejo, CI/CD, sovereign Git.
# Key decisions: docs/adr/ADR-70-forge.md

{ config, lib, pkgs, ... }:

# ── Forge Module ──────────────────────────────────────────────────────

{
  options.my.forge = {
    enable = lib.mkEnableOption "forge module";
  };

  config = lib.mkIf config.my.forge.enable {
    # TODO: Forgejo, CI/CD
  };
}
