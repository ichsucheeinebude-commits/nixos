# ---NIXMETA
# ---
# domain: 40
# id: "NIXH-40-MON-003"
# title: "ntfy-sh"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [monitoring,ntfy,alerting]
# description: "Local ntfy-sh notification server."
# path: "modules/40-monitoring/42-ntfy.nix"
# provides: [my.monitoring.ntfy]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/40-monitoring/42-ntfy.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### 🏗️ 1. USER LAYER: WER SIEHT WAS? (KISS)
#
# - **Admin (Du):** Braucht volle Kontrolle, RSS-Feeds, Server-Stats und Arrr-Queues.
# - **Familie:** Braucht nur drei Knöpfe: Filme, Serien, Hörbücher. Alles andere würde nur verwirren.
#
# ---
# ### A. Admin Dashboard: Glance
#
# - **Warum:** Einzelne Go-Binary, extrem leichtgewichtig (<20MB RAM).
# - **Features:** Widgets für Sonarr/Radarr, RSS-Feeds, Wetter, Server-Stats.
# - **NixOS-Integration:** Reine YAML-Konfiguration, perfekt deklarativ.
# ─── End KB Nuggets ───

{ config, lib, ... }:
{
  options.my.monitoring.ntfy = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 2586; };
  };

  config = lib.mkIf config.my.monitoring.ntfy.enable {
    services.ntfy-sh = {
      enable = true;
      settings = {
        listen-http = "127.0.0.1:${toString config.my.monitoring.ntfy.port}";
        behind-proxy = true;
      };
    };
  };
}
