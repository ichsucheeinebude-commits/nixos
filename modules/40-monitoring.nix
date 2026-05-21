# ---NIXMETA---
# domain: 40-monitoring
# id: NIXH-40-MON-001
# status: draft
# provides:
#   - my.monitoring.enable
# requires:
#   - 00-core
#   - 10-network
# adr: ADR-40-monitoring.md
# guide: 40-monitoring.md
# complexity: 2
# reviewed: YYYY-MM-DD
# ---ENDNIXMETA---
#
# PURPOSE: Netdata, Gatus, Scrutiny.
# Key decisions: docs/adr/ADR-40-monitoring.md

{ config, lib, pkgs, ... }:

# ── Monitoring Module ─────────────────────────────────────────────────

{
  options.my.monitoring = {
    enable = lib.mkEnableOption "monitoring module";
  };

  config = lib.mkIf config.my.monitoring.enable {
    # TODO: Netdata, Gatus, Scrutiny
  };
}
