# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-70-FOR-001",
#   "title": "Forge — Self-Hosted Git",
#   "layer": 70,
#   "category": "forge",
#   "lastReviewed": "YYYY-MM-DD",
#   "reviewedBy": "moritz",
#   "status": "draft",
#   "complexity": 2,
#   "description": "Forgejo, CI/CD, sovereign Git strategy",
#   "tags": ["forgejo", "git", "ci-cd"]
# }
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

# ── Forge Module ──────────────────────────────────────────────────────

{
  options.my.forge = {
    enable = lib.mkEnableOption "forge module";
  };

  config = lib.mkIf config.my.forge.enable {
    # TODO: Forgejo, CI/CD
  };
}
