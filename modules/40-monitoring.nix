# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-40-MON-001",
#   "title": "Monitoring #   "title": "Monitoring & Observability", Observability",
#   "layer": 40,
#   "category": "monitoring",
#   "lastReviewed": "YYYY-MM-DD",
#   "reviewedBy": "moritz",
#   "status": "draft",
#   "complexity": 2,
#   "description": "Netdata, Gatus, Scrutiny",
#   "tags": ["monitoring", "netdata", "gatus", "scrutiny"]
# }
# ---ENDNIXMETA

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
