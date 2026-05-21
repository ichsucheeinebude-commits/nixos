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
# nms_id: APP-TOOLS-AI-AGENTS
# title: Ai Agents (Ollama & Claude)
# capabilities: [ "ai", "gpu" ]
# status: "hardened"
# tier_strategy: "ABC-v5.1"
# ---
{ config, lib, pkgs, ... }:
let
 # 🚀 NMS v4.0 Metadaten
 nms = {
 id = "NIXH-30-AUT-002";
 title = "Ai Agents (Ollama & Claude)";
 description = "Local AI orchestration with Ollama (GPU-accelerated) and Claude Code.";
 layer = 20;
 nixpkgs.category = "services/misc";
 capabilities = [ "ai/ollama" "ai/claude-code" "gpu/acceleration" ];
 audit.last_reviewed = "2026-03-02";
 audit.complexity = 2;
 };

 kimiClaudeScript = pkgs.writeShellScriptBin "kimi-claude" "echo '🤖 Starting AI...'; ${pkgs.ollama}/bin/ollama run kimi-k2.5:cloud; ${pkgs.nodejs_22}/bin/npx -y @anthropic-ai/claude-code --model kimi-k2.5:cloud";
in
{
 options.my.meta.ai_agents = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 description = "NMS metadata for ai-agents module";
 };


 config = lib.mkIf config.my.services.aiAgents.enable {
 services.ollama = {
 enable = true;
 package = if config.my.configs.hardware.intelGpu then pkgs.ollama-vulkan else pkgs.ollama;
 loadModels = [ "kimi-k2.5:cloud" ];
 };
 environment.systemPackages = [ kimiClaudeScript pkgs.ollama pkgs.nodejs_22 ];
 programs.bash.shellAliases.kimi = "kimi-claude";
 systemd.services.ollama.serviceConfig = { DeviceAllow = [ "/dev/dri/renderD128 rw" ]; ProtectSystem = "strict"; ProtectHome = true; PrivateTmp = true; OOMScoreAdjust = 500; };
 };
}
