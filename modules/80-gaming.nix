# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-80-GAM-001",
#   "title": "Gaming #   "title": "Gaming & Game Servers", Game Servers",
#   "layer": 80,
#   "category": "gaming",
#   "lastReviewed": "YYYY-MM-DD",
#   "reviewedBy": "moritz",
#   "status": "draft",
#   "complexity": 2,
#   "description": "FHS environments for game servers, AMP",
#   "tags": ["gaming", "amp", "fhs", "game-servers"]
# }
# ---ENDNIXMETA

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
