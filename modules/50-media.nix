# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-001"
# title: "Media Stack"
# type: module
# status: draft
# complexity: 3
# reviewed: YYYY-MM-DD
# tags:
#   - media
#   - jellyfin
#   - sonarr
#   - radarr
# description: "Jellyfin, Arr-stack, QuickSync"
# provides:
#   - my.media.enable
# requires:
#   - 00-core
#   - 10-network
#   - 30-storage
# links:
#   adr: ADR-50-media.md
#   guide: 50-media.md
#   module: modules/50-media.nix
# ---
# ---ENDNIXMETA

---
#
# PURPOSE: Jellyfin, Arr-stack, QuickSync.
# Key decisions: docs/adr/ADR-50-media.md

{ config, lib, pkgs, ... }:

# ── Media Module ──────────────────────────────────────────────────────

{
  options.my.media = {
    enable = lib.mkEnableOption "media module";
  };

  config = lib.mkIf config.my.media.enable {
    # TODO: Jellyfin, Arr-stack, QuickSync
  };
}
