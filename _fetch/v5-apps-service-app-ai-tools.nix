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

# ---
# nms_id: APP-TOOLS-AI-TOOLS
# title: AI Tools (SRE Assisted)
# capabilities: [ "ai", "shell" ]
# status: "hardened"
# tier_strategy: "ABC-v5.1"
# ---
{ pkgs, lib, config, ... }:
let
 # 🚀 NMS v4.0 Metadaten
 nms = {
 id = "NIXH-00-COR-002";
 title = "AI Tools (SRE Assisted)";
 description = "Optimized terminal environment for AI-assisted development and SRE tasks.";
 layer = 00;
 nixpkgs.category = "tools/admin";
 capabilities = [ "ai/workflow" "shell/enhancement" ];
 audit.last_reviewed = "2026-03-02";
 audit.complexity = 1;
 };
in
{
 options.my.meta.ai_tools = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 description = "NMS metadata for ai-tools module";
 };

 options.my.tools.ai.enable = lib.mkEnableOption "AI Tools (aider, uv, etc.)";

 config = lib.mkIf config.my.tools.ai.enable {
 # ── SRE TOOLBELT ────────────────────────────────────────────────────────
 environment.systemPackages = with pkgs; [
 aider-chat uv python3 blesh inshellisense fzf jq curl
 ];

 # ── SHELL UI ENHANCEMENT ────────────────────────────────────────────────
 programs.bash.interactiveShellInit = ''
 # Integriert blesh für Syntax-Highlighting und Auto-Suggestions
 if [[ -f ${pkgs.blesh}/share/blesh/ble.sh ]]; then
 source ${pkgs.blesh}/share/blesh/ble.sh
 bleopt edit_multi_line=0 2>/dev/null || true
 fi

 # AI Integration Aliase
 if command -v inshellisense > /dev/null; then
 alias gemini-hint='inshellisense bind gemini -- gemini'
 fi
 '';
 };
}
