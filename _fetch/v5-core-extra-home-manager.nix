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

{
 config,
 lib,
 pkgs,
 inputs,
 ...
}: let
 # 🚀 NMS v4.2 Metadaten (hardened Home)
 nms = {
 id = "NIXH-00-COR-013";
 title = "Home Manager (User Cockpit)";
 description = "Hardened user environment. Git SSoT and Shell-Secret integration.";
 layer = 00;
 nixpkgs.category = "tools/admin";
 capabilities = ["user/environment" "shell/hardening" "git/configuration"];
 audit.last_reviewed = "2026-04-27";
 audit.complexity = 2;
 source_repo = "grapefruit89/mynixos";
 };
 
 user = config.my.configs.identity.user;
in {
 options.my.meta.home_manager = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 };

 # Home-Manager Modul laden
 imports = [ inputs.home-manager.nixosModules.home-manager ];

 config = {
 home-manager = {
 useGlobalPkgs = true;
 useUserPackages = true;
 backupFileExtension = "hm-backup";
 
 users.${user} = { pkgs, ... }: {
 home.stateVersion = "24.05"; # 💎 Stable anchor. # see docs/NIXOS_VERSION_INFO.md – this is the current stable channel, not future music.
 
 # Importiert user-moritz-home.nix
 imports = [ (./user-${user}-home.nix) ];

 # 🔧 GIT CONFIGURATION (Fragment 4425 Alignment)
 programs.git = {
 enable = true;
 userName = "Moritz";
 userEmail = "git@${config.my.configs.identity.domain}";
 extraConfig = {
 init.defaultBranch = "main";
 pull.rebase = true;
 core.editor = "micro";
 };
 aliases = {
 st = "status";
 co = "checkout";
 br = "branch";
 up = "pull --rebase";
 };
 };

 # 🏎️ SHELL & ENVIRONMENT
 programs.bash = {
 enable = true;
 shellAliases = {
 # Gemini Godmode (Aligned with Project Path)
 godmode = "gemini --yolo --include-directories /etc/nixos,$(pwd)";
 };
 };
 };
 };
 };
}
