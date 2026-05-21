# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-001"
# title: "Applications"
# type: module
# status: draft
# complexity: 2
# reviewed: YYYY-MM-DD
# tags:
#   - apps
#   - paperless
#   - n8n
#   - vaultwarden
# description: "Paperless, n8n, Vaultwarden"
# provides:
#   - my.apps.enable
# requires:
#   - 00-core
#   - 10-network
#   - 20-security
# links:
#   adr: ADR-60-apps.md
#   guide: 60-apps.md
#   module: modules/60-apps.nix
# ---
# ---ENDNIXMETA

---
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
