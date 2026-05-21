# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-50-MED-001",
#   "title": "Media Stack",
#   "layer": 50,
#   "category": "media",
#   "lastReviewed": "YYYY-MM-DD",
#   "reviewedBy": "moritz",
#   "status": "draft",
#   "complexity": 3,
#   "description": "Jellyfin, Arr-stack, QuickSync",
#   "tags": ["media", "jellyfin", "sonarr", "radarr", "prowlarr"]
# }
# ---ENDNIXMETA

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
