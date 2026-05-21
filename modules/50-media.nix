# ---NIXMETA---
# domain: 50-media
# id: NIXH-50-MED-001
# status: draft
# provides:
#   - my.media.enable
# requires:
#   - 00-core
#   - 10-network
#   - 30-storage
# adr: ADR-50-media.md
# guide: 50-media.md
# complexity: 3
# reviewed: YYYY-MM-DD
# ---ENDNIXMETA---
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
