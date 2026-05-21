# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-022"
# title: "Open WebUI"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [apps,ai,llm,webui,ollama,sandboxing,dynamic-user]
# description: "User-friendly WebUI for LLMs, tightly sandboxed with DynamicUser and privacy controls."
# path: "modules/60-apps/72-open-webui.nix"
# provides: [my.apps.openWebui]
# requires: [my.network.caddy, my.core.ports]
# links:
#   adr: docs/adr/ADR-72-open-webui.md
#   guide: docs/guides/72-open-webui.md
#   module: modules/60-apps/72-open-webui.nix
#   upstream: https://github.com/open-webui/open-webui
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Ollama bietet API-Zugriff auf lokale LLMs, aber keine benutzerfreundliche
# Oberfläche. Open WebUI füllt diese Lücke — Chat-Interface, Modelle-Verwaltung,
# alles deklarativ in NixOS.
#
# ### Entscheidung
#
# **Open WebUI Pattern:**
# 1.  **services.open-webui** — NixOS-native Modul.
# 2.  **Ollama Integration** — Automatische OLLAMA_API_BASE_URL.
# 3.  **Privacy Controls** — SCARF_NO_ANALYTICS, DO_NOT_TRACK, ANONYMIZED_TELEMETRY.
# 4.  **DynamicUser Sandboxing** — Kein fester User, strict security.
# 5.  **GPU Access** — SupplementaryGroups für render/video (Hardware-Beschleunigung).
#
# ### SRE-Standards
#
# - DynamicUser = true (kein persistenter User).
# - ProtectSystem = strict, ProtectHome = true.
# - SystemCallFilter = ["@system-service" "~@privileged"].
# - SupplementaryGroups = ["render" "video"] für GPU-Zugriff.
# - OOMScoreAdjust = 200 (kann bei Speicherknappheit gekillt werden).
# ─── End KB Nuggets ───

{ config, lib, ... }:

let
  port = config.my.core.ports.openWebui or 3080;
  domain = config.my.core.identity.domain;
in
{
  options.my.apps.openWebui = {
    enable = lib.mkEnableOption "Open WebUI for LLM interaction";
    port = lib.mkOption {
      type = lib.types.port;
      default = port;
      description = "Port for Open WebUI service.";
    };
    ollamaPort = lib.mkOption {
      type = lib.types.port;
      default = config.my.core.ports.ollama or 11434;
      description = "Port for local Ollama instance.";
    };
    ollamaUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:${toString config.my.apps.openWebui.ollamaPort}";
      description = "URL of the Ollama API endpoint.";
    };
  };

  config = lib.mkIf config.my.apps.openWebui.enable {
    services.open-webui = {
      enable = true;
      host = "127.0.0.1";
      port = config.my.apps.openWebui.port;
      environment = {
        OLLAMA_API_BASE_URL = config.my.apps.openWebui.ollamaUrl;
        SCARF_NO_ANALYTICS = "True";
        DO_NOT_TRACK = "True";
        ANONYMIZED_TELEMETRY = "False";
      };
    };

    # ── Caddy Reverse Proxy ──
    services.caddy.virtualHosts."ai.${domain}" = {
      extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString config.my.apps.openWebui.port}";
    };

    # ── Systemd Sandboxing (DynamicUser) ──
    systemd.services.open-webui.serviceConfig = {
      DynamicUser = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      SupplementaryGroups = [ "render" "video" ];
      SystemCallFilter = [ "@system-service" "~@privileged" ];
      OOMScoreAdjust = 200;
    };
  };
}
