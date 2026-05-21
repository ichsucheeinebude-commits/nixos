# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-AUTO-GEN",
#   "title": "Auto Generated",
#   "layer": 99,
#   "category": "auto/gen",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["auto-generated"],
#   "description": "Auto-migrated module to NIXMETA 2.0."
# }
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
let
 # 🚀 NMS v4.0 Metadaten
 nms = {
 id = "NIXH-30-AUT-001";
 title = "Automation";
 description = "Core automation settings, including sudo rules for rebuilds and maintenance.";
 layer = 20;
 nixpkgs.category = "system/settings";
 capabilities = [ "system/maintenance" "security/sudo-rules" ];
 audit.last_reviewed = "2026-03-02";
 audit.complexity = 2;
 };

 bastelmodus = config.my.configs.bastelmodus;
 user = config.my.configs.identity.user;
in
{
 options.my.meta.automation = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 description = "NMS metadata for automation module";
 };

 config = {
 security.sudo.extraRules = [
 {
 users = [ user ];
 commands = [
 { command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild"; options = [ "NOPASSWD" ]; }
 { command = "${pkgs.nix}/bin/nix"; options = [ "NOPASSWD" ]; }
 { command = "${pkgs.nix}/bin/nix-collect-garbage"; options = [ "NOPASSWD" ]; }
 { command = "ALL"; options = lib.mkIf bastelmodus [ "NOPASSWD" ]; }
 ];
 }
 ];
 };
}
