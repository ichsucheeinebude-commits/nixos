# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-60-APP-001",
#   "title": "Applications",
#   "layer": 60,
#   "category": "apps",
#   "lastReviewed": "YYYY-MM-DD",
#   "reviewedBy": "moritz",
#   "status": "draft",
#   "complexity": 2,
#   "description": "Paperless, n8n, Vaultwarden, and additional web apps",
#   "tags": ["apps", "paperless", "n8n", "vaultwarden"]
# }
# ---ENDNIXMETA

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
