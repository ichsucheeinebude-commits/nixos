# ---NIXMETA---
# domain: 80-gaming
# id: NIXH-80-GAM-001
# status: draft
# provides:
#   - my.gaming.enable
# requires:
#   - 00-core
#   - 10-network
#   - 30-storage
# adr: ADR-80-gaming.md
# guide: 80-gaming.md
# complexity: 2
# reviewed: YYYY-MM-DD
# ---ENDNIXMETA---
#
# PURPOSE: FHS game servers, AMP.
# Key decisions: docs/adr/ADR-80-gaming.md

{ config, lib, pkgs, ... }:

# ── Gaming Module ─────────────────────────────────────────────────────

{
  options.my.gaming = {
    enable = lib.mkEnableOption "gaming module";
  };

  config = lib.mkIf config.my.gaming.enable {
    # TODO: FHS game servers, AMP
  };
}
