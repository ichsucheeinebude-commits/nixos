# ---NIXMETA
# ---
# domain: 40
# id: "NIXH-40-MON-006"
# title: "Uptime Kuma"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [monitoring,uptime-kuma,uptime]
# description: "Uptime Kuma monitoring dashboard."
# path: "modules/40-monitoring/45-uptime-kuma.nix"
# provides: [my.monitoring.uptimeKuma]
# requires: []
# links:
#   adr: docs/adr/ADR-45-uptime-kuma.md
#   guide: docs/guides/45-uptime-kuma.md
#   module: modules/40-monitoring/45-uptime-kuma.nix
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
  options.my.monitoring.uptimeKuma = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 3001; };
  };

  config = lib.mkIf config.my.monitoring.uptimeKuma.enable {
    services.uptime-kuma = {
      enable = true;
      settings.PORT = toString config.my.monitoring.uptimeKuma.port;
    };
  };
}
