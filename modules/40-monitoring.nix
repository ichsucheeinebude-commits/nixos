# ---NIXMETA
# ---
# domain: 40
# id: "NIXH-40-MON-001"
# title: "Monitoring and Observability"
# type: module
# status: draft
# complexity: 2
# reviewed: YYYY-MM-DD
# tags:
#   - monitoring
#   - netdata
#   - gatus
#   - scrutiny
# description: "Netdata, Gatus, Scrutiny"
# provides:
#   - my.monitoring.enable
# requires:
#   - 00-core
#   - 10-network
# links:
#   adr: ADR-40-monitoring.md
#   guide: 40-monitoring.md
#   module: modules/40-monitoring.nix
# ---
# ---ENDNIXMETA

---
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
