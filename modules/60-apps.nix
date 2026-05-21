# ---NIXMETA---
# domain: 60-apps
# id: NIXH-60-APP-001
# status: draft
# provides:
#   - my.apps.enable
# requires:
#   - 00-core
#   - 10-network
#   - 20-security
# adr: ADR-60-apps.md
# guide: 60-apps.md
# complexity: 2
# reviewed: YYYY-MM-DD
# ---ENDNIXMETA---
#
# PURPOSE: Paperless, n8n, Vaultwarden.
# Key decisions: docs/adr/ADR-60-apps.md

{ config, lib, pkgs, ... }:

# ── Apps Module ───────────────────────────────────────────────────────

{
  options.my.apps = {
    enable = lib.mkEnableOption "apps module";
  };

  config = lib.mkIf config.my.apps.enable {
    # TODO: Paperless, n8n, Vaultwarden
  };
}
