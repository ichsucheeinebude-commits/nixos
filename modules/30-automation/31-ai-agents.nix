# ---NIXMETA
# ---
# domain: 30
# id: "NIXH-30-AUT-002"
# title: "AI Agents (Ollama & Claude)"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [ai,ollama,claude-code,gpu,local-llm]
# description: "Local AI orchestration with Ollama (GPU-accelerated) and Claude Code integration."
# path: "modules/30-automation/31-ai-agents.nix"
# provides: [my.automation.aiAgents]
# requires: [00-core]
# links:
#   module: modules/30-automation/31-ai-agents.nix
# source: _meta/30-automation/service-app-ai-agents.nix (NIXH-30-AUT-002)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
  cfg = config.my.automation.aiAgents;
in
{
  options.my.automation.aiAgents = {
    enable = lib.mkEnableOption "Local AI (Ollama + Claude Code)";
    models = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "llama3.1:8b" ];
      description = "Models to pre-load.";
    };
    useVulkan = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use Vulkan for Intel iGPU acceleration.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = if cfg.useVulkan then pkgs.ollama-vulkan else pkgs.ollama;
      loadModels = cfg.models;
    };

    systemd.services.ollama.serviceConfig = {
      DeviceAllow = [ "/dev/dri/renderD128 rw" ];
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      OOMScoreAdjust = 500;
    };
  };
}
